#!/bin/sh

# Install Xcodegen
brew install xcodegen

# Go to Project Directory
cd ..

# Generate the Xcode project
xcodegen generate

echo "Current Directory: $(pwd)"
ls -la

# Resolve Swift package dependencies and create the Package.resolved file
xcodebuild -project Kapal-Lawd.xcodeproj -scheme Kapal-Lawd -verbose
