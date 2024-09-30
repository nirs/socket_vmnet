#!/bin/bash
set -e
cd "$(dirname "$0")"

TIME=${2:-10}

create() {
    limactl create --name server --tty=false lima.yaml &
    limactl create --name client --tty=false lima.yaml &
    wait
}

setup() {
    limactl start server &
    limactl start client &
    wait
    nohup limactl shell server iperf3 --server --daemon
}

run() {
    server_address=$(limactl shell server ip -j -4 addr show dev lima0 | jq -r '.[0].addr_info[0].local')
    limactl shell client iperf3 --client $server_address --time $TIME
}

cleanup() {
    limactl stop server
    limactl stop client
}

delete() {
    limactl delete -f server
    limactl delete -f client
}

case $1 in
create)
    create
    ;;
setup)
    setup
    ;;
run)
    run
    ;;
cleanup)
    cleanup
    ;;
delete)
    delete
    ;;
*)
    echo "Usage $0 create|setup|run [TIME]|cleanup|delete"
    ;;
esac
