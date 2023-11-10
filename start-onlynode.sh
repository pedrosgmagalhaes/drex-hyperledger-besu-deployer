nohup besu --data-path=data \
--genesis-file=../genesis.json \
--permissions-accounts-contract-enabled  \
--permissions-accounts-contract-address "0x0000000000000000000000000000000000008888" \
--permissions-nodes-contract-enabled \
--min-gas-price=0 \
--permissions-nodes-contract-address "0x0000000000000000000000000000000000009999" \
--permissions-nodes-contract-version=2 \
--rpc-http-enabled \
--rpc-http-api=ETH,NET,WEB3,QBFT \
--rpc-ws-enabled \
--rpc-ws-api=ETH,NET,WEB3,QBFT \
--graphql-http-enabled \
--host-allowlist="*" \
--rpc-http-cors-origins="*" \
--rpc-http-host=0.0.0.0 \
--rpc-ws-host=0.0.0.0 \
--graphql-http-host=0.0.0.0 \
> besu.log 2>&1 &

 nohup besu --data-path=data --genesis-file=../genesis.json --bootnodes="enode://527b6f57bc9efd9074d01bfd4561dc11c181296cb574ed69de2f4485bfc7a2d9678818217b650eb45d6e5e26678eece1943cfa36c14f50990c335a40a0baa7a1@127.0.0.1:30303" --p2p-port=30304 --rpc-http-enabled --rpc-http-api=ETH,NET,QBFT --host-allowlist="*" --rpc-http-cors-origins="all" --rpc-http-port=8546 > besu.log 2>&1 &
 nohup besu --data-path=data --genesis-file=../genesis.json --bootnodes="enode://527b6f57bc9efd9074d01bfd4561dc11c181296cb574ed69de2f4485bfc7a2d9678818217b650eb45d6e5e26678eece1943cfa36c14f50990c335a40a0baa7a1@127.0.0.1:30303" --p2p-port=30305 --rpc-http-enabled --rpc-http-api=ETH,NET,QBFT --host-allowlist="*" --rpc-http-cors-origins="all" --rpc-http-port=8547 > besu.log 2>&1 &
 nohup besu --data-path=data --genesis-file=../genesis.json --bootnodes="enode://527b6f57bc9efd9074d01bfd4561dc11c181296cb574ed69de2f4485bfc7a2d9678818217b650eb45d6e5e26678eece1943cfa36c14f50990c335a40a0baa7a1@127.0.0.1:30303" --p2p-port=30306 --rpc-http-enabled --rpc-http-api=ETH,NET,QBFT --host-allowlist="*" --rpc-http-cors-origins="all" --rpc-http-port=8548 > besu.log 2>&1 &


besu --data-path=data --genesis-file=../genesis.json --permissions-accounts-contract-enabled --permissions-accounts-contract-address "0x0000000000000000000000000000000000008888" --permissions-nodes-contract-enabled  --permissions-nodes-contract-address "0x0000000000000000000000000000000000009999" --permissions-nodes-contract-version=2 --rpc-http-enabled --rpc-http-cors-origins="*" --rpc-http-api=ADMIN,ETH,NET,PERM,IBFT --host-allowlist="*"
besu --data-path=data --genesis-file=../genesis.json --bootnodes="enode://527b6f57bc9efd9074d01bfd4561dc11c181296cb574ed69de2f4485bfc7a2d9678818217b650eb45d6e5e26678eece1943cfa36c14f50990c335a40a0baa7a1@127.0.0.1:30303" --permissions-accounts-contract-enabled --permissions-accounts-contract-address "0x0000000000000000000000000000000000008888" --permissions-nodes-contract-enabled  --permissions-nodes-contract-address "0x0000000000000000000000000000000000009999" --permissions-nodes-contract-version=2 --rpc-http-enabled --rpc-http-cors-origins="*" --rpc-http-api=ADMIN,ETH,NET,PERM,IBFT --host-allowlist="*" --p2p-port=30304 --rpc-http-port=8556