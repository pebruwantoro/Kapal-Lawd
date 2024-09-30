#!/bin/sh

# Install Xcodegen
brew install xcodegen

# Go to Project Directory
cd ..

# Generate the Xcode project
xcodegen generate

cat ./Kapal-Lawd.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved


# Resolve Swift package dependencies
xcodebuild -project Kapal-Lawd.xcodeproj -scheme Kapal-Lawd -resolvePackageDependencies

xcodebuild -project Kapal-Lawd.xcodeproj -scheme Kapal-Lawd -verbose
