docker run -d \
  --mount type=bind,source="$(pwd)"/genesis.json,target=/opt/besu/genesis.json \
  -e BESU_RPC_HTTP_ENABLED=true \
  -e BESU_RPC_HTTP_API=ETH,NET,WEB3,ADMIN \
  -e BESU_RPC_WS_ENABLED=true \
  -e BESU_RPC_WS_API=ETH,NET,WEB3,ADMIN \
  -e BESU_P2P_ENABLED=true \
  -e BESU_P2P_DISCOVERY_ENABLED=true \
  hyperledger/besu:latest \
  --genesis-file=/opt/besu/genesis.json \
  --bootnodes="enode://ca63e8f7193f116c62c596fa036896cccbfa71f8c9bb72ce0cab20b0b795824f2f5fa456b72e2186ae70bf6d3e73136e0083ae17dc90173dc348ec6512af60f4@10.106.16.2:30303" \
  --host-whitelist="*" \
  --rpc-http-host=0.0.0.0 \
  --rpc-ws-host=0.0.0.0
