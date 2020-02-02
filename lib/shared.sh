#!/bin/bash

set -euo pipefail

CACHE_DIR=/tmp/asdf-xcode.cache
XCODERELEASES_PATH="${CACHE_DIR}/xcodereleases-data.json"
XCODERELEASES_URL="https://xcodereleases.com/data.json"

function assert_darwin() {
    [ "$(uname -s)" = Darwin ] || {
        echo "This plugin only works on macOS. Aborting."
        exit 1
    }
}

function assert_jq_installed() {
    [ -x "$(command -v jq)" ] || {
        echo "Install $(tput bold)jq$(tput sgr0) to continue. Aborting." >&2
        exit 1
    }
}

function cache_is_out_of_date() {
    [ -z "$(ls -A "$CACHE_DIR")" ] || [ "$(set -- "$(stat -f %c "$CACHE_DIR"/*)" && echo "$1")" -le $(($(date +%s) - 3600)) ]
}

function fetch_xcodereleases_data_if_needed() {
    if ! cache_is_out_of_date; then
        return 0
    fi
    curl \
        --silent \
        --location \
        --write-out "%{filename_effective}\n" \
        -o "$XCODERELEASES_PATH" \
        "$XCODERELEASES_URL"
}

function xcodereleases_json() {
    jq '.' "$XCODERELEASES_PATH"
}

function load_environment() {
    assert_darwin && assert_jq_installed
    mkdir -p $CACHE_DIR
    fetch_xcodereleases_data_if_needed
}

function get_apple_cookie() {
    echo ""
}

function download_xcode() {
    local url="$1"
    local output_dir="$2"
    local cookie
    cookie=$(get_apple_cookie)

    cd "$output_dir"

    curl \
        --silent \
        --location \
        --cookie "$cookie" \
        --progress-bar \
        --continue \
        --remote-name \
        "$url"
}
