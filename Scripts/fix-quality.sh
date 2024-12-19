#!/bin/bash

set -e

Scripts/install-pkgx.sh

eval "$(pkgx --shellcode)"
env +swiftlint

echo "Fixing quality..."
swiftlint --fix && swiftlint
echo "... done."