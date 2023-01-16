#!/bin/bash

set -e

echo "... checking Swift code..."
swiftlint --quiet --strict
echo "... checking Ruby scripts..."
bundle exec rubocop --format quiet
echo "... checking Shell scripts..."
shellcheck Scripts/*.sh hooks/*
echo "... checking Markdown documentation..."
bundle exec mdl --style markdown_style.rb docs .github Sources/**/*.docc
echo "... checking YAML files..."
yamllint .*.yml .github
