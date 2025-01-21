#!/bin/bash

set -e

function install_tools {
    curl -Ssf https://pkgx.sh | sh &> /dev/null
    eval "$(pkgx +swiftlint)"
}

install_tools

echo "Fixing quality..."
swiftlint --fix && swiftlint
echo "... done."