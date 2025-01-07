#!/bin/bash

ROOT_DIR="$1"
KEYCHAIN_PASSWORD="$2"
APPLE_CERTIFICATE_BASE64="$3"
APPLE_CERTIFICATE_PASSWORD="$4"

if [[ -z $ROOT_DIR || -z $KEYCHAIN_PASSWORD || -z $APPLE_CERTIFICATE_BASE64 || -z $APPLE_CERTIFICATE_PASSWORD ]]
then
    echo "[!] Usage: $0 <ROOT_DIR> <KEYCHAIN_PASSWORD> <APPLE_CERTIFICATE_BASE64 (base64)> <APPLE_CERTIFICATE_PASSWORD>"
    exit 1
fi

KEYCHAIN_PATH="$ROOT_DIR/app-signing.keychain-db"
APPLE_CERTIFICATE="$ROOT_DIR/certificate.p12"

echo -n "$APPLE_CERTIFICATE_BASE64" | base64 --decode -o "$APPLE_CERTIFICATE"

# Create a temporary keychain (https://docs.github.com/en/actions/using-github-hosted-runners/using-github-hosted-runners/about-github-hosted-runners)
security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"

# Import certificate
security import "$APPLE_CERTIFICATE" -k "$KEYCHAIN_PATH" -P "$APPLE_CERTIFICATE_PASSWORD" -A -t cert -f pkcs12
# Authorize access to certificate private key
security set-key-partition-list -S apple-tool:,apple: -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
# Set the default keychain
security list-keychain -d user -s "$KEYCHAIN_PATH"
