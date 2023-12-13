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
            # Extract and format the node ID from the public key
            public_key=$(cat $PWD/$node_dir/data/key.pub)
            formatted_key=$(echo ${public_key#0x}) # remove '0x' prefix if present
            node_id=$(echo -n $formatted_key | xxd -r -p | openssl dgst -sha3-256 -binary | xxd -p -c 64)
            echo $node_id > $PWD/config/bootnode_id
        fi
    else
        echo "Error: Key generation for $node_dir failed."
        exit 1
    fi
}



# Ask the user for the number of nodes
read -p "Enter the number of nodes (including the bootnode): " num_nodes

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

    # Append to docker-compose.yaml
    cat >> docker-compose.yaml << EOF
  $node_dir:
    container_name: $node_dir
    image: hyperledger/besu:latest
    entrypoint:
      - /bin/bash
      - -c
      - |
        sleep $((i*10));
        /opt/besu/bin/besu --data-path=/opt/besu/data --bootnodes=enode://\$(cat /opt/besu/config/bootnode_id)@172.16.240.30:30303 --config-file=/opt/besu/config.toml --genesis-file=/opt/besu/genesis.json 
    volumes:
      - ./config.toml:/opt/besu/config.toml
      - ./genesis.json:/opt/besu/genesis.json
      - ./config:/opt/besu/config
      - ./$node_dir/data:/opt/besu/data
    networks:
      besu-network:
        ipv4_address: 172.16.240.$((30+i-1))

EOF
    echo "Node $node_dir setup complete."
done

echo "All nodes have been set up."
echo "Setup Complete. Docker compose file created."
