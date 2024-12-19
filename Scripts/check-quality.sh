#!/bin/bash

set -e

echo "Checking quality..."

Scripts/install-pkgx.sh

eval "$(pkgx --shellcode)"

echo "... checking Swift code..."
env +swiftlint
if [[ "$1" == "--only-changes" ]]; then
  git diff --staged --name-only | grep ".swift$" | xargs swiftlint lint --quiet --strict
else
  swiftlint --quiet --strict
fi

echo "... checking Ruby scripts..."
rm -rf ~/.pkgx/sqlite.org # Avoid https://github.com/pkgxdev/pkgx/issues/1059
pkgx rubocop --format quiet

echo "... checking Shell scripts..."
pkgx shellcheck Scripts/*.sh hooks/* Artifacts/**/*.sh

echo "... checking Markdown documentation..."
pkgx markdownlint --ignore fastlane .

echo "... checking YAML files..."
pkgx yamllint .*.yml .github

echo "... done."