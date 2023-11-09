docker run -d -p 30303:30303 -p 30303:30303/udp -p 8545:8545 -p 8546:8546 \
  --mount type=bind,source="$(pwd)"/genesis.json,target=/opt/besu/genesis.json \
  -e BESU_RPC_HTTP_ENABLED=true \
  -e BESU_RPC_HTTP_API=ETH,NET,WEB3,ADMIN \
  -e BESU_RPC_WS_ENABLED=true \
  -e BESU_RPC_WS_API=ETH,NET,WEB3,ADMIN \
  -e BESU_P2P_ENABLED=true \
  -e BESU_P2P_DISCOVERY_ENABLED=true \
  -e BESU_RPC_HTTP_CORS_ORIGINS="*" \
  -e BESU_RPC_WS_HOST=0.0.0.0 \
  -e BESU_RPC_HTTP_HOST=0.0.0.0 \
  hyperledger/besu:latest \
  --genesis-file=/opt/besu/genesis.json \
  --bootnodes="enode://daf4f0456e565c2d8f5cf44fca88dd42876058a231e3656ddd8644734d5fd373fe55787d2b1f26b3b8757ad8e3c990ed0ea20536625bffa1b571d90d2691e747@10.106.16.2:30303" \
  --rpc-http-port=8545 \
  --rpc-ws-port=8546 \
  --host-whitelist="*" \
  --rpc-http-cors-origins="*" \
  --rpc-http-host=0.0.0.0 \
  --rpc-ws-host=0.0.0.0
