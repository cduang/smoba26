#!/bin/sh

# This script is used to build the TrollSpeed app and create a tipa file with Xcode.
if [ $# -ne 1 ]; then
    echo "Usage: $0 <version>"
    exit 1
fi

VERSION=$1

# Strip leading "v" from version if present
VERSION=${VERSION#v}

# Build using Xcode
xcodebuild clean build archive \
-scheme TrollSpeed \
-project THOR-HUD.xcodeproj \
-sdk iphoneos \
-destination 'generic/platform=iOS' \
-archivePath TrollSpeed \
CODE_SIGNING_ALLOWED=NO | xcpretty

cp supports/TS.entitlements TrollSpeed.xcarchive/Products
cd TrollSpeed.xcarchive/Products/Applications
codesign --remove-signature Apibug-HUD.app
cd -
cd TrollSpeed.xcarchive/Products
mv Applications Payload
ldid -STS.entitlements Payload/Apibug-HUD.app
zip -qr Apibug-HUD.tipa Payload
cd -
mkdir -p packages
mv TrollSpeed.xcarchive/Products/Apibug-HUD.tipa packages/TrollSpeed.tipa
