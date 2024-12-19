#!/bin/bash

set -e

eval "$(pkgx --shellcode)"

env +gem +bundle

echo "Installing bundler..."
bundle config set path '.bundle'
bundle install
echo "... done."
