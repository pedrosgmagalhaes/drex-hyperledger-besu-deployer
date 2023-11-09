docker run -d \
  --mount type=bind,source="$(pwd)"/genesis.json,target=/opt/besu/genesis.json \
  --mount type=bind,source="$(pwd)"/key.priv,target=/opt/besu/key.priv \
  hyperledger/besu:latest \
  --genesis-file=/opt/besu/genesis.json \
  --node-private-key-file=/opt/besu/key.priv \
  --bootnodes="enode://b7f04229f180072a93067bcc6504ef52466aaa77a9f723272058220c0d1e2e8cd758c602b5d3b139c035ec4059ee97d65f04d9c70f9df5d10cc871bc7787458f@10.106.16.2:30303" \
  --host-whitelist="*" \
  --rpc-http-host=0.0.0.0 \
  --rpc-ws-host=0.0.0.0
