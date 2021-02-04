#!/usr/bin/env bash

XCODES_VERSION="${ASDF_XCODES_VERSION:-0.16.0}"
XCODES_TAG="$XCODES_VERSION"

echoerr() {
    echo >&2 -e "\033[0;31m$1\033[0m"
}

function assert_darwin() {
    [ "$(uname -s)" = Darwin ] || {
        echo "This plugin only works on macOS. Aborting."
        exit 1
    }
}

ensure_xcodes_setup() {
    assert_darwin && ensure_xcodes_installed
}

ensure_xcodes_installed() {
    if [ ! -f "$(xcodes_path)" ]; then
        download_xcodes
    else
        current_xcodes_version="$("$(xcodes_path)" --version | cut -d ' ' -f2)"

        if [ "$current_xcodes_version" != "$XCODES_VERSION" ]; then
            # If the xcodes directory already exists and the version does not
            # match, remove it and download the correct version
            rm -rf "$(xcodes_dir)"
            download_xcodes
        fi
    fi
}

download_xcodes() {
    # Print to stderr so asdf doesn't assume this string is a list of versions
    echoerr "Downloading xcodes..."

    local download_dir
    download_dir="$(xcodes_download_dir)"

    # Remove directory in case it still exists from last download
    rm -rf "$download_dir"
    mkdir -p "$download_dir"
    cd "$download_dir" || exit

    curl \
        --location \
        --remote-name \
        --remote-header-name \
        "https://github.com/RobotsAndPencils/xcodes/releases/download/$XCODES_TAG/xcodes.zip" >&2 >/dev/null
    
    cd - || exit

    mkdir -p "$(xcodes_bin_dir)"
    unzip "$download_dir/xcodes.zip" -d "$(xcodes_bin_dir)"

    # Remove xcodes download dir
    rm -rf "$download_dir"
}

asdf_xcode_plugin_path() {
    dirname "$(dirname "$0")"
}

xcodes_dir() {
    echo "$(asdf_xcode_plugin_path)/xcodes"
}

xcodes_bin_dir() {
    echo "$(xcodes_dir)/bin"
}

xcodes_path() {
    echo "$(xcodes_bin_dir)/xcodes"
}

xcodes_download_dir() {
    echo "$(asdf_xcode_plugin_path)/xcodes-download"
}
