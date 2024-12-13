#!/bin/bash

set -e

echo "Installing bundler..."
pkgx bundle config set path '.bundle'
pkgx bundle install
echo "... done."
