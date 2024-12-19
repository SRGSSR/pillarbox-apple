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

if [[ $IS_INTERACTIVE == true ]]; then
    source Scripts/set-apple-api-env-interactively.sh
    Scripts/configure-environment.sh "$APPLE_API_KEY_BASE64"
fi

Scripts/install-pkgx.sh
Scripts/install-bundler.sh

pkgx bundle exec fastlane "archive_demo_$PLATFORM"
echo "... done."