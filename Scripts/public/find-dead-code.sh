#!/bin/bash

function install_tools {
    curl -Ssf https://pkgx.sh | sh &> /dev/null
    eval "$(pkgx --shellcode)"
    env +periphery
}

install_tools

echo "Start checking dead code..."
mkdir -p .build
xcodebuild -scheme Pillarbox -destination generic/platform=iOS -derivedDataPath ./.build/derived-data clean build &> /dev/null
periphery scan --retain-public --skip-build --index-store-path ./.build/derived-data/Index.noindex/DataStore/
xcodebuild -scheme Pillarbox-demo -project ./Demo/Pillarbox-demo.xcodeproj -destination generic/platform=iOS -derivedDataPath ./.build/derived-data clean build &> /dev/null
periphery scan --project ./Demo/Pillarbox-demo.xcodeproj --schemes Pillarbox-demo --targets Pillarbox-demo --skip-build --index-store-path ./.build/derived-data/Index.noindex/DataStore/
echo "... done."