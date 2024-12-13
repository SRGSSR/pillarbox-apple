#!/bin/bash

set -e

function usage {
    echo
    echo "[!] Usage: $0 [--non-interactive] --platform [ios | tvos]"
    echo
    echo "      Params:"
    echo "          --non-interactive: (Optional) Avoid setting the ENV variables interactively (interactive by default)."
    echo "          --platform: (Required) Platform for which to archive the demo."
    echo
    exit 1
}

PLATFORM=""
IS_INTERACTIVE=true

if [[ $1 == "--non-interactive" && $2 == "--platform" ]]; then
    IS_INTERACTIVE=false
    PLATFORM="$3"
elif [[ $1 == "--platform" ]]; then
    PLATFORM="$2"
else
    usage
fi

if [[ $PLATFORM != "ios" && $PLATFORM != "tvos" ]]; then
   usage
fi

echo -e "Archiving $PLATFORM demo..."

TEAM_ID=""
KEY_ISSUER_ID=""
KEY_ID=""
APPLE_API_KEY_BASE64=""

if [[ $IS_INTERACTIVE == true ]]; then
    echo "Please provide information related to your Apple account:"
    echo
    read -rp "  TEAM_ID: " TEAM_ID
    read -rp "  KEY_ISSUER_ID: " KEY_ISSUER_ID
    read -rp "  KEY_ID: " KEY_ID
    read -rp "  APPLE_API_KEY_BASE64: " APPLE_API_KEY_BASE64
    export TEAM_ID
    export KEY_ISSUER_ID
    export KEY_ID
    echo
    "$(dirname "$0")/configure-environment.sh" "$APPLE_API_KEY_BASE64"
fi

"$(dirname "$0")/install-pkgx.sh"
"$(dirname "$0")/install-bundler.sh"

pkgx bundle exec fastlane "archive_demo_$PLATFORM"
echo "... done"