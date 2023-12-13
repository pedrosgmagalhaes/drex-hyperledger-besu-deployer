# drex-hyperledger-besu-deployer

## Overview
The `drex-hyperledger-besu-deployer` is a tool designed to streamline the process of building and deploying nodes for a Hyperledger Besu network. This tool is inspired by Drex, a Central Bank Digital Currency (CBDC) infrastructure from Brazil. It enables users to deploy a similar network in seconds.

## Requirements
- Docker
- Docker Compose
- A bash shell environment for running scripts (available on Linux, Mac, and Windows via Git Bash or similar)

## Features
- Fast setup and deployment of Hyperledger Besu nodes.
- User-friendly interface for specifying the number of nodes.
- Automatic key generation for each node.

## Getting Started
1. Ensure Docker and Docker Compose are installed on your machine.
2. Clone this repository.
3. Navigate to the cloned directory and run the setup script.


## Installation
To install the `drex-hyperledger-besu-deployer`, follow these steps:
1. Download or clone the repository.
2. Open a Linux, Mac, or Windows terminal (Windows users can use Git Bash or a similar bash shell).
3. Navigate to the directory containing the `install.sh` script.
4. Run the installation script with the following command:
   ```bash
   sh install.sh
   ```
This script will set up everything you need to get started.

## Dockerfile
```Dockerfile
FROM hyperledger/besu:latest

# Copy necessary scripts or configuration files
COPY qbftConfigFile.json /qbftConfigFile.json

# Set the entrypoint to Besu
ENTRYPOINT ["/opt/besu/bin/besu"]

## Setup Script
```bash
#!/bin/bash

# Check for Docker installation and running status
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker and retry."
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "Error: Docker is not running. Please start Docker and retry."
    exit 1
fi

echo "Success: Docker is installed and running."

# Define a function to generate keys with Besu
generate_keys() {
    # Additional script commands go here...
}

# Main script to configure and set up nodes
# Additional setup commands go here...

echo "Setup Complete: All configuration files have been created."
```

## Configuration
Adjust the `genesis.json` file and other necessary settings to align with your specific network requirements. This step is crucial for tailoring the deployment to your desired Hyperledger Besu network configuration.

## Usage
Once the setup is complete, you can launch your Hyperledger Besu network with the following command:
```bash
docker-compose up -d
```

## Be a Node - CBDC Simulator
By using this setup, you can emulate the operation of a node in a CBDC (Central Bank Digital Currency) network. This provides an immersive and educational experience, closely mirroring the functionality of the Drex infrastructure.

## Author
Pedro Magalhães - [GitHub Profile](https://github.com/pedrosgmagalhaes)

## Contributing
Contributions are welcome and greatly appreciated. If you have any suggestions for improvements or notice any issues, please feel free to submit pull requests or open issues on the repository. For more of my work and contributions, visit my [GitHub](https://github.com/pedrosgmagalhaes).

## License
This project is licensed under the MIT License. For more information, see the [LICENSE](LICENSE) file in the repository.
