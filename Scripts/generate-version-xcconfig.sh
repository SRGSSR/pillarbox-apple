#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "usage: $(basename "$0") repository_directory output_directory"
    exit 1
fi

if ! SHORT_VERSION=$(git --git-dir "$1/.git" describe --tags --abbrev=0 2> /dev/null); then
    SHORT_VERSION="0.0.0"
fi

mkdir -p "$2"
GENERATED_FILE_PATH="$2/Version.xcconfig"

cat > "$GENERATED_FILE_PATH" <<- EOF
// This file is generated automatically. Do not modify.
MARKETING_VERSION = $SHORT_VERSION
CURRENT_PROJECT_VERSION = 1
EOF
