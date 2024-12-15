#!/bin/bash

set -e

function usage {
    echo
    echo "[!] Usage: $0 --platform [ios | tvos]"
    echo
    exit 1
}

if [[ "$1" != "--platform" ]]; then
    usage
fi

PLATFORM="$2"
if [[ $PLATFORM != "ios" && $PLATFORM != "tvos" ]]; then
    usage
fi

Scripts/test-streams.sh -s

Scripts/install-pkgx.sh
Scripts/install-bundler.sh

echo "Running unit tests..."
pkgx +xcodes bundle exec fastlane "test_$PLATFORM"
echo "... done."

Scripts/test-streams.sh -k