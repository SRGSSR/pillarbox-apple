#!/bin/bash

GENERATED_FILE_PATH="$2/PackageInfo.swift"

if [ "$#" -ne 2 ]; then
    echo "usage: $(basename "$0") repository_directory output_directory"
    exit 1
fi

if ! version=$(git --git-dir "$1/.git" describe --tags 2> /dev/null); then
    version="0.0.0"
fi

if ! short_version=$(git --git-dir "$1/.git" describe --tags --abbrev=0 2> /dev/null); then
    short_version="0.0.0"
fi

cat > "$GENERATED_FILE_PATH" <<- EOF
// This file is generated automatically. Do not modify.
import Foundation

enum PackageInfo {
    static let version = "$version"
    static let shortVersion = "$short_version"
}
EOF
