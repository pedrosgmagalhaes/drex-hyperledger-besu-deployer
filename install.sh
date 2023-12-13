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
        --genesis-file=/opt/besu/genesis.json \
        --rpc-http-enabled \
        --rpc-http-cors-origins="*" \
        --min-gas-price=0 \
        --p2p-host="0.0.0.0" \
        --p2p-port=30303 \
        --p2p-enabled=true \
        --discovery-enabled=true \
        --max-peers=25 \
        --metrics-enabled \
        --rpc-ws-enabled \
        --permissions-accounts-config-file-enabled \
        --permissions-accounts-config-file=/opt/besu/config/accounts_config.toml \
        --permissions-nodes-config-file-enabled \
        --permissions-nodes-config-file=/opt/besu/config/nodes_config.toml \
        --rpc-http-api=ADMIN,ETH,NET,PERM,QBFT
    volumes:
      - ./config.toml:/opt/besu/config.toml
      - ./genesis.json:/opt/besu/genesis.json
      - ./config/bootnode_id:/opt/besu/config/bootnode_id
      - ./config/accounts_config.toml:/opt/besu/config/accounts_config.toml
      - ./config/nodes_config.toml:/opt/besu/config/nodes_config.toml
      - ./$node_dir/data:/opt/besu/data
    ports:
      - 30303:30303
      - 8545:8545
      - 8546:8546
      - 8547:8547
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
        --bootnodes=enode://\$(cat /opt/besu/config/bootnode_id)@172.16.240.30:30303 \
        --config-file=/opt/besu/config.toml \
        --genesis-file=/opt/besu/genesis.json \
        --metrics-enabled \
        --rpc-ws-enabled \
        --permissions-accounts-config-file-enabled \
        --permissions-accounts-config-file=/opt/besu/config/accounts_config.toml \
        --permissions-nodes-config-file-enabled \
        --permissions-nodes-config-file=/opt/besu/config/nodes_config.toml \
        --rpc-http-api=ADMIN,ETH,NET,PERM,QBFT
    volumes:
      - ./config.toml:/opt/besu/config.toml
      - ./genesis.json:/opt/besu/genesis.json
      - ./config/bootnode_id:/opt/besu/config/bootnode_id
      - ./config/accounts_config.toml:/opt/besu/config/accounts_config.toml
      - ./config/nodes_config.toml:/opt/besu/config/nodes_config.toml
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


# Generate permissions_config.toml
echo "Generating nodes_config.toml and ccounts_config.toml files..."
nodes_allowlist=()
accounts_allowlist=()

for (( i=1; i<=num_nodes; i++ ))
do
    if [[ $i -eq 1 ]]; then
        node_dir="bootnode"
    else
        node_dir="node$((i-1))"
    fi

    # Extract the enode URL
    node_id=$(cat $PWD/$node_dir/data/key.pub | sed 's/^0x//')
    enode_url="enode://$node_id@172.16.240.$((30+i-1)):30303"
    nodes_allowlist+=("\"$enode_url\"")

    # Generate the Ethereum account address from the private key file
    account_address=$(docker run --rm -v $PWD/$node_dir/data:/opt/besu/data hyperledger/besu:latest public-key export-address --node-private-key-file=/opt/besu/data/key --ec-curve=secp256k1 | tail -n 1 )
    accounts_allowlist+=("\"$account_address\"")
done

# Generate nodes_config.toml
echo "Generating nodes_config.toml..."
printf "nodes-allowlist=[%s]\n" "$(IFS=, ; echo "${nodes_allowlist[*]}")" > $PWD/config/nodes_config.toml
echo "nodes_config.toml generated."

# Generate accounts_config.toml
echo "Generating accounts_config.toml..."
printf "accounts-allowlist=[%s]\n" "$(IFS=, ; echo "${accounts_allowlist[*]}")" > $PWD/config/accounts_config.toml
echo "accounts_config.toml generated."

echo "Setup Complete. Configuration files created."
