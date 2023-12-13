#!/bin/bash

# Check if Docker is installed and running
if ! command -v docker &> /dev/null; then
    echo "Docker could not be found. Please install Docker and try again."
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "Docker is not running. Please start Docker and try again."
    exit 1
fi

echo "Docker is installed and running."

# Function to generate keys using Besu in Docker
generate_keys() {
    node_dir=$1
    echo "Generating keys for $node_dir..."
    docker run --rm -v $PWD/config:/opt/besu/config -v $PWD/$node_dir/data:/opt/besu/data hyperledger/besu:latest operator generate-blockchain-config --config-file=/opt/besu/config/qbftConfigFile.json --to=/opt/besu/data --private-key-file-name=key

    first_folder=$(ls $PWD/$node_dir/data/keys | head -n 1)
    if [ -d "$PWD/$node_dir/data/keys/$first_folder" ]; then
        mv $PWD/$node_dir/data/keys/$first_folder/* $PWD/$node_dir/data
        rm -r $PWD/$node_dir/data/keys
        echo "Keys generated for $node_dir."

        if [[ $node_dir == "bootnode" ]]; then
            # Extract the node ID from the public key by removing '0x' prefix
            node_id=$(cat $PWD/$node_dir/data/key.pub | sed 's/^0x//')
            echo "Node ID for $node_dir: $node_id"
            echo $node_id > $PWD/config/bootnode_id
            # Copy the genesis.json from the bootnode to a common location
            cp $PWD/$node_dir/data/genesis.json $PWD/config/
            echo "Removing genesis.json from $node_dir and moving to config folder"
        fi
        rm -rf $PWD/$node_dir/data/genesis.json
    else
        echo "Error: Key generation for $node_dir failed."
        exit 1
    fi
}

# Ask the user for the number of nodes
num_nodes=0
while [[ $num_nodes -lt 4 ]]; do
    read -p "Enter the number of nodes (including the bootnode, minimum 4): " num_nodes
    if [[ $num_nodes -lt 4 ]]; then
        echo "You must create at least 4 nodes. Please try again."
    fi
done


# Create a directory for config if it doesn't exist
echo "Setting up configuration..."
mkdir -p config
cp qbftConfigFile.json config/
echo "Configuration setup complete."

# Initial docker-compose.yaml content
cat > docker-compose.yaml << EOF
version: "3.4"

networks:
  besu-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.16.240.0/24

services:
EOF

# Loop to setup each node
echo "Setting up nodes..."
for (( i=1; i<=num_nodes; i++ ))
do
    if [[ $i -eq 1 ]]; then
        node_dir="bootnode"
    else
        node_dir="node$((i-1))"
    fi

    mkdir -p $node_dir/data
    generate_keys $node_dir

    if [[ $node_dir == "bootnode" ]]; then
        # Bootnode configuration
        cat >> docker-compose.yaml << EOF
  $node_dir:
    container_name: $node_dir
    image: hyperledger/besu:latest
    entrypoint:
      - /bin/bash
      - -c
      - |
        /opt/besu/bin/besu --data-path=/opt/besu/data \
        --genesis-file=/opt/besu/genesis.json --rpc-http-enabled \
        --host-allowlist="*" --rpc-http-cors-origins="all" \
        --rpc-http-api=ETH,NET,QBFT;
    volumes:
      - ./config/bootnode_id:/opt/besu/config/bootnode_id
      - ./config/genesis.json:/opt/besu/genesis.json
      - ./$node_dir/data:/opt/besu/data
    ports:
      - 30303:30303
      - 8545:8545
    networks:
      besu-network:
        ipv4_address: 172.16.240.30
EOF
    else
        # Other nodes configuration
        cat >> docker-compose.yaml << EOF
  $node_dir:
    container_name: $node_dir
    image: hyperledger/besu:latest
    entrypoint:
      - /bin/bash
      - -c
      - |
        sleep $((i*10));
        /opt/besu/bin/besu --data-path=/opt/besu/data \
        --genesis-file=/opt/besu/genesis.json --rpc-http-enabled \
        --bootnodes=enode://\$(cat /opt/besu/config/bootnode_id)@172.16.240.30:30303 --p2p-port=30303 \
        --host-allowlist="*" --rpc-http-cors-origins="all"
    volumes:
      - ./config/bootnode_id:/opt/besu/config/bootnode_id
      - ./config/genesis.json:/opt/besu/genesis.json
      - ./$node_dir/data:/opt/besu/data
    depends_on:
      - bootnode
    networks:
      besu-network:
        ipv4_address: 172.16.240.$((30+i-1))
EOF
    fi
    echo "Node $node_dir setup complete."
done

echo "Setup Complete. Configuration files created."
