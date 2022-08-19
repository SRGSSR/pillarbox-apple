#!/bin/bash

pushd "$(dirname "$0")/.." > /dev/null || exit
xcodebuild docbuild -scheme Appearance -destination generic/platform=iOS
xcodebuild docbuild -scheme CoreBusiness -destination generic/platform=iOS
xcodebuild docbuild -scheme Diagnostics -destination generic/platform=iOS
xcodebuild docbuild -scheme Player -destination generic/platform=iOS
xcodebuild docbuild -scheme UserInterface -destination generic/platform=iOS
popd > /dev/null || exit
