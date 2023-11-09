docker run -d \
  --mount type=bind,source="$(pwd)"/genesis.json,target=/opt/besu/genesis.json \
  --mount type=bind,source="$(pwd)"/key.priv,target=/opt/besu/key.priv \
  hyperledger/besu:latest \
  --genesis-file=/opt/besu/genesis.json \
  --node-private-key-file=/opt/besu/key.priv \
  --bootnodes="enode://1af64001226251d5e583b871f3cd56f5be75bab6c03792c63580105f2db832bcd50646fd66d7f4d3f4af0e40b9cdbb78ef1fcd90572c4052ada872afe872e7ba@10.106.16.2:30303" \
  --host-whitelist="*" \
  --rpc-http-host=0.0.0.0 \
  --rpc-ws-host=0.0.0.0
