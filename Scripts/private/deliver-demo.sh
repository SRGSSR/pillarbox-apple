#!/bin/bash

set -e

function usage {
    echo
    echo "Usage: $0 -p [ios | tvos] -c [nightly | release]"
    echo
    exit 1
}

function install_tools {
    curl -Ssf https://pkgx.sh | sh &> /dev/null
    eval "$(pkgx --shellcode)"
    env +bundle +magick +rsvg-convert
}

while getopts p:c: OPT; do
    case "$OPT" in
        p)
            PLATFORM=$OPTARG
            ;;
        c)
            CONFIGURATION=$OPTARG
            ;;
        *)
            usage
            ;;
    esac
done

if [[ $PLATFORM != "ios" && $PLATFORM != "tvos" ]]; then
    usage
fi

if [[ $CONFIGURATION != "nightly" && $CONFIGURATION != "release" ]]; then
    usage
fi

install_tools

echo -e "Delivering demo $CONFIGURATION build for $PLATFORM..."
bundle config set path '.bundle'
bundle install
bundle exec fastlane "deliver_demo_${CONFIGURATION}_${PLATFORM}"
echo "... done."