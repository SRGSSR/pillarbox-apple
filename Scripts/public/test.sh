#!/bin/bash

set -e

function usage {
    echo
    echo "Usage: $0 -p [ios | tvos]"
    echo
    exit 1
}

function install_tools {
    curl -Ssf https://pkgx.sh | sh &> /dev/null
    set -a
    eval "$(pkgx +ruby@3.3.0 +bundle +xcodes)"
    set +a
}

if [[ -z "$1" ]]; then
    usage
fi

while getopts p: OPT; do
    case "$OPT" in
        p)
            PLATFORM=$OPTARG
            ;;
        *)
            usage
            ;;
    esac
done

if [[ $PLATFORM != "ios" && $PLATFORM != "tvos" ]]; then
    usage
fi

install_tools

echo "Running unit tests..."
bundle config set path '.bundle'
bundle install
bundle exec fastlane "test_$PLATFORM"
echo "... done."
