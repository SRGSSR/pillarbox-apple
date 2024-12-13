#!/bin/bash

set -e

function usage {
    echo
    echo "[!] Usage: $0 [--non-interactive] --platform [ios | tvos] --configuration [nightly | release]"
    echo
    echo "      Params:"
    echo "          --non-interactive: (Optional) Avoid setting the ENV variables interactively (interactive by default)."
    echo "          --platform: (Required) Platform for which to deliver the demo."
    echo "          --configuration: (Required) Configuration for which to deliver the demo."
    echo
    exit 1
}

PLATFORM=""
CONFIGURATION=""
IS_INTERACTIVE=true

if [[ $1 == "--non-interactive" && $2 == "--platform" && $4 == "--configuration" ]]; then
    IS_INTERACTIVE=false
    PLATFORM="$3"
    CONFIGURATION="$5"
elif [[ $1 == "--platform" && $3 == "--configuration" ]]; then
    PLATFORM="$2"
    CONFIGURATION="$4"
else
    usage
fi

if [[ $PLATFORM != "ios" && $PLATFORM != "tvos" ]]; then
   usage
fi

if [[ $CONFIGURATION != "nightly" && $CONFIGURATION != "release" ]]; then
   usage
fi

echo -e "Delivering demo $CONFIGURATION build for $PLATFORM..."

if [[ $IS_INTERACTIVE == true ]]; then
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

    "$(dirname "$0")/configure-environment.sh" "$APPLE_API_KEY_BASE64"
fi

"$(dirname "$0")/install-pkgx.sh"
"$(dirname "$0")/install-bundler.sh"

eval "$(pkgx --shellcode)"
env +bundle +magick +rsvg-convert

bundle exec fastlane "deliver_demo_${CONFIGURATION}_${PLATFORM}"
echo "... done"