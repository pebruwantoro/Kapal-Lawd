#!/bin/sh

# Install Xcodegen
brew install xcodegen

# Go to Project Directory
cd ..

# Generate the Xcode project
xcodegen generate

# Resolve Swift package dependencies and create the Package.resolved file
xcodebuild -resolvePackageDependencies -project Kapal-Lawd.xcodeproj

# Ensure package dependencies are correctly set
xcodebuild build -project Kapal-Lawd.xcodeproj -scheme Kapal-Lawd