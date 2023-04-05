#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "usage: $(basename "$0") repository_directory output_directory"
    exit 1
fi

if ! VERSION=$(git --git-dir "$1/.git" describe --tags 2> /dev/null); then
    echo "No tag was found in the specified repository."
    exit 1
fi

if ! SHORT_VERSION=$(git --git-dir "$1/.git" describe --tags --abbrev=0 2> /dev/null); then
    echo "No tag was found in the specified repository."
    exit 1
fi

GENERATED_FILE_PATH="$2/PackageInfo.swift"

cat > "$GENERATED_FILE_PATH" <<- EOF
// This file is generated automatically. Do not modify.
import Foundation

enum PackageInfo {
    static let version = "$VERSION"
    static let shortVersion = "$SHORT_VERSION"
}
EOF
