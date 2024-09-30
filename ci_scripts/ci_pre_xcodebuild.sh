#!/bin/sh

echo "Current Directory: $(pwd)"
ls -la

# Check if the project was generated successfully
if [ ! -d "Kapal-Lawd.xcodeproj" ]; then
    echo "Failed to generate Xcode project."
    exit 1
fi

# Resolve Swift Package Manager dependencies
xcodebuild -resolvePackageDependencies -project ./Kapal-Lawd.xcodeproj -scheme Kapal-Lawd -allowProvisioningUpdates