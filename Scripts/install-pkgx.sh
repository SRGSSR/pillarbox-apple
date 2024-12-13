#!/bin/bash

set -e

echo "Installing pkgx..."
curl -Ssf https://pkgx.sh | sh &> /dev/null
echo "... done."
