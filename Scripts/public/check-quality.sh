#!/bin/bash

set -e

function usage {
    echo
    echo "Usage: $0 [OPTION]"
    echo "   -c         check only changes."
    echo
    exit 1
}

function install_tools {
    curl -Ssf https://pkgx.sh | sh &> /dev/null
    set -a
    eval "$(pkgx +swiftlint +shellcheck +markdownlint)"
    set +a
}

while getopts c OPT; do
    case "$OPT" in
        c)
            ONLY_CHANGES=true
            ;;
        *)
            usage
            ;;
    esac
done

install_tools

echo "Checking quality..."

echo "... checking Swift code..."
if [[ "$ONLY_CHANGES" == true ]]; then
    git diff --staged --name-only | grep ".swift$" | xargs swiftlint lint --quiet --strict
else
    swiftlint --quiet --strict
fi

echo "... checking Ruby scripts..."
rm -rf ~/.pkgx/sqlite.org # Avoid https://github.com/pkgxdev/pkgx/issues/1059
pkgx rubocop --format quiet

echo "... checking Shell scripts..."
shellcheck Scripts/**/*.sh hooks/* Artifacts/**/*.sh

echo "... checking Markdown documentation..."
markdownlint --ignore fastlane .

echo "... checking YAML files..."
pkgx yamllint .*.yml .github

echo "... done."