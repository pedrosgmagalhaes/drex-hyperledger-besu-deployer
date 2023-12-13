# Dockerfile
FROM hyperledger/besu:latest

# Copy any necessary scripts or configuration files
COPY qbftConfigFile.json /qbftConfigFile.json

# Set the entrypoint to Besu
ENTRYPOINT ["/opt/besu/bin/besu"]
