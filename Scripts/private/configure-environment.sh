#!/bin/bash

APPLE_API_KEY_BASE64="$1"

if [[ -z $APPLE_API_KEY_BASE64 ]]
then
    echo "[!] Usage: $0 <APPLE_API_KEY_BASE64>"
    exit 1
fi

mkdir -p Configuration
echo "$APPLE_API_KEY_BASE64" | base64 --decode > Configuration/AppStoreConnect_API_Key.p8
