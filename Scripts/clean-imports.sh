#!/bin/bash

echo "Cleaning imports..."
mkdir -p .build
xcodebuild -scheme Pillarbox -destination generic/platform=ios > ./.build/xcodebuild.log
pkgx swiftlint analyze --fix --compiler-log-path ./.build/xcodebuild.log
xcodebuild -scheme Pillarbox-demo -project ./Demo/Pillarbox-demo.xcodeproj -destination generic/platform=iOS > ./.build/xcodebuild.log
pkgx swiftlint analyze --fix --compiler-log-path ./.build/xcodebuild.log
echo "... done."