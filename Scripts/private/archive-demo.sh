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
    eval "$(pkgx --shellcode)"
    env +bundle
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

echo -e "Archiving $PLATFORM demo..."
bundle config set path '.bundle'
bundle install
bundle exec fastlane "archive_demo_$PLATFORM"
echo "... done."