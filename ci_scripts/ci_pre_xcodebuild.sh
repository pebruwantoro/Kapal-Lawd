#!/bin/bash

# Change to the project directory
cd ..

# Resolve Swift package dependencies
echo "Resolving Swift package dependencies..."
if [ -f "Kapal-Lawd.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved" ]; then
    echo "Package.resolved already exists."
else
    echo "Resolving packages..."
    xcodebuild -resolvePackageDependencies -project Kapal-Lawd.xcodeproj
fi