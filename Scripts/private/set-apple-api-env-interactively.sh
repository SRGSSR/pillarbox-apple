#!/bin/bash

TEAM_ID=""
KEY_ISSUER_ID=""
KEY_ID=""
APPLE_API_KEY_BASE64=""

echo "Please provide information related to your Apple account:"
echo
read -rp "  TEAM_ID: " TEAM_ID
read -rp "  KEY_ISSUER_ID: " KEY_ISSUER_ID
read -rp "  KEY_ID: " KEY_ID
read -rp "  APPLE_API_KEY_BASE64: " APPLE_API_KEY_BASE64

if [[ -z "$TEAM_ID" || -z "$KEY_ISSUER_ID" || -z "$KEY_ID" || -z "$APPLE_API_KEY_BASE64" ]]; then
    echo
    [[ -z "$TEAM_ID" ]] && echo "  TEAM_ID is missing!"
    [[ -z "$KEY_ISSUER_ID" ]] && echo "  KEY_ISSUER_ID is missing!"
    [[ -z "$KEY_ID" ]] && echo "  KEY_ID is missing!"
    [[ -z "$APPLE_API_KEY_BASE64" ]] && echo "  APPLE_API_KEY_BASE64 is missing!"
    exit 1
fi
echo

export TEAM_ID
export KEY_ISSUER_ID
export KEY_ID
export APPLE_API_KEY_BASE64