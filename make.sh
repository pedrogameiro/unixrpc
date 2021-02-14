#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
# Pedro Gameiro wrote this file.  As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return.   Poul-Henning Kamp
# ----------------------------------------------------------------------------
set -o errexit                                       # abort on nonzero exitstatus
set -o nounset                                       # abort on unbound variable
set -o pipefail                                      # don't hide errors within pipes
cd "$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")" # Start in the script directory

Red=$'\e[0;31m'   # Red
Green=$'\e[0;32m' # Green
Blue=$'\e[0;34m'  # Blue
NC=$'\e[0m'       # Color Reset

main() {
    local argv=("$@")
    local argc="${#argv[@]}"

    mkdir -p {go,cpp}/build/proto
    protoc -I proto \
        --go_out='go/build' --go-grpc_out='go/build' \
        --plugin=protoc-gen-grpc="$(which grpc_cpp_plugin)" --cpp_out='cpp/build/proto' --grpc_out='cpp/build/proto' \
        'proto/messages/messages.proto'

    go build -o go/build/client ./go/src

    g++ $(pkg-config grpc++ protobuf --libs) -I cpp/build/proto \
        -o ./cpp/build/server \
        cpp/src/main.cpp cpp/build/proto/messages/*.cc
}

main "${@}"

# vim:set shiftwidth=4 softtabstop=4 expandtab:
