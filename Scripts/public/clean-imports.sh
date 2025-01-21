#!/bin/bash

function install_tools {
    curl -Ssf https://pkgx.sh | sh &> /dev/null
    eval "$(pkgx +swiftlint)"
}

install_tools

echo "Cleaning imports..."
mkdir -p .build
xcodebuild -scheme Pillarbox -destination generic/platform=ios > ./.build/xcodebuild.log
swiftlint analyze --fix --compiler-log-path ./.build/xcodebuild.log
xcodebuild -scheme Pillarbox-demo -project ./Demo/Pillarbox-demo.xcodeproj -destination generic/platform=iOS > ./.build/xcodebuild.log
swiftlint analyze --fix --compiler-log-path ./.build/xcodebuild.log
echo "... done."