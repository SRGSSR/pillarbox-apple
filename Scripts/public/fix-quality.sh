#!/bin/bash

set -e

function install_tools {
    brew install pkgx &> /dev/null
    set -a
    eval "$(pkgx +swiftlint)"
    set +a
}

install_tools

echo "Fixing quality..."
swiftlint --fix && swiftlint
echo "... done."
