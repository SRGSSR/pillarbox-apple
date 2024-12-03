#!/bin/bash

pushd "$(dirname "$0")/.." > /dev/null || exit
xcodebuild docbuild -scheme PillarboxAnalytics -destination generic/platform=iOS
xcodebuild docbuild -scheme PillarboxCircumspect -destination generic/platform=iOS
xcodebuild docbuild -scheme PillarboxCore -destination generic/platform=iOS
xcodebuild docbuild -scheme PillarboxCoreBusiness -destination generic/platform=iOS
xcodebuild docbuild -scheme PillarboxMonitoring -destination generic/platform=iOS
xcodebuild docbuild -schemePillarboxPlayer -destination generic/platform=iOS
popd > /dev/null || exit
