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
    source Scripts/set-apple-api-env-interactively.sh
    Scripts/configure-environment.sh "$APPLE_API_KEY_BASE64"
fi

Scripts/install-pkgx.sh
Scripts/install-bundler.sh

eval "$(pkgx --shellcode)"
env +bundle +magick +rsvg-convert

bundle exec fastlane "deliver_demo_${CONFIGURATION}_${PLATFORM}"
echo "... done."