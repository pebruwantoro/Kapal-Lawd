#!/bin/sh

# Install Xcodegen
if ! command -v xcodegen &> /dev/null; then
    brew install xcodegen
fi

# Check if xcodebuild is available
if ! command -v xcodebuild &> /dev/null; then
    echo "xcodebuild is not installed. Please install Xcode command line tools."
    exit 1
fi

echo "Current Directory: $(pwd)"
ls -la

# Go to Project Directory
cd ..

echo "Current Directory: $(pwd)"
ls -la

# Generate the Xcode project
if ! xcodegen generate; then
    echo "Failed to generate Xcode project."
    exit 1
fi

# Check if the project was generated successfully
if [ ! -d "Kapal-Lawd.xcodeproj" ]; then
    echo "Failed to generate Xcode project."
    exit 1
fi

# Resolve Swift Package Manager dependencies
xcodebuild -resolvePackageDependencies -project ./Kapal-Lawd.xcodeproj -scheme Kapal-Lawd -allowProvisioningUpdates
