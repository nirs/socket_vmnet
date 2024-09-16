#!/bin/bash
set -e
cd "$(dirname "$0")"

TIME=${2:-10}

setup() {
    limactl start --name server --tty=false lima.yaml &
    limactl start --name client --tty=false lima.yaml &
    wait
    nohup limactl shell server iperf3 --server --daemon
}

run() {
    server_address=$(limactl shell server ip -j -4 addr show dev lima0 | jq -r '.[0].addr_info[0].local')
    limactl shell client iperf3 --client $server_address --no-delay --time $TIME
}

cleanup() {
    limactl delete -f server
    limactl delete -f client
}

case $1 in
setup)
    setup
    ;;
run)
    run
    ;;
cleanup)
    cleanup
    ;;
*)
    echo "Usage $0 setup|run [TIME]|cleanup"
    ;;
esac
