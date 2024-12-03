#!/bin/bash

eval "$(pkgx --shellcode)"
env +xcbeautify

pushd "$(dirname "$0")/.." > /dev/null || exit
xcodebuild docbuild -scheme PillarboxAnalytics -destination generic/platform=iOS | xcbeautify --renderer github-actions
xcodebuild docbuild -scheme PillarboxCircumspect -destination generic/platform=iOS | xcbeautify --renderer github-actions
xcodebuild docbuild -scheme PillarboxCore -destination generic/platform=iOS | xcbeautify --renderer github-actions
xcodebuild docbuild -scheme PillarboxCoreBusiness -destination generic/platform=iOS | xcbeautify --renderer github-actions
xcodebuild docbuild -scheme PillarboxMonitoring -destination generic/platform=iOS | xcbeautify --renderer github-actions
xcodebuild docbuild -scheme PillarboxPlayer -destination generic/platform=iOS | xcbeautify --renderer github-actions
popd > /dev/null || exit
