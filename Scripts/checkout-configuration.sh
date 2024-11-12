#!/bin/bash

# This script attempts to checkout a configuration repository URL and to switch to a specific commit.

CONFIGURATION_REPOSITORY_URL=$1
CONFIGURATION_COMMIT_SHA1=$2
CONFIGURATION_FOLDER=$3

if [[ -z "$CONFIGURATION_REPOSITORY_URL" ]]; then
    echo "A configuration repository URL must be provided."
    exit 1
fi

if [[ -z "$CONFIGURATION_COMMIT_SHA1" ]]; then
    echo "A configuration commit SHA1 must be provided."
    exit 1
fi

if [[ -z "$CONFIGURATION_FOLDER" ]]; then
    echo "A configuration destination folder must be provided."
    exit 1
fi

if [[ ! -d "$CONFIGURATION_FOLDER" ]]; then
    if git clone "$CONFIGURATION_REPOSITORY_URL" "$CONFIGURATION_FOLDER" &> /dev/null; then
        echo "Private configuration details were successfully cloned under the '$CONFIGURATION_FOLDER' folder."
    else
        echo "Your GitHub account cannot access private project configuration details. Skipped."
        exit 0
    fi
else
    echo "A '$CONFIGURATION_FOLDER' folder is already available."
fi

pushd "$CONFIGURATION_FOLDER" > /dev/null || exit

if ! git status &> /dev/null; then
    echo "The '$CONFIGURATION_FOLDER' folder is not a valid git repository."
    exit 1
fi

if [[ $(git status --porcelain 2> /dev/null) ]]; then
    echo "The repository '$CONFIGURATION_FOLDER' contains changes. Please commit or discard these changes and retry."
    exit 1
fi

git fetch &> /dev/null

if git checkout -q "$CONFIGURATION_COMMIT_SHA1" &> /dev/null; then
    echo "The '$CONFIGURATION_FOLDER' repository has been switched to commit $CONFIGURATION_COMMIT_SHA1."
else
    echo "The repository '$CONFIGURATION_FOLDER' could not be switched to commit $CONFIGURATION_COMMIT_SHA1. Does this commit exist?"
    exit 1
fi

popd > /dev/null || exit

ln -fs "$CONFIGURATION_FOLDER/.env" .
