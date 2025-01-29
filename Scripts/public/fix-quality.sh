#!/bin/bash

set -e

function install_tools {
    curl -Ssf https://pkgx.sh | sh &> /dev/null
    set -a
    eval "$(pkgx +swiftlint)"
    set +a
}

install_tools

echo "Fixing quality..."
swiftlint --fix && swiftlint
echo "... done."