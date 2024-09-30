#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Change to the project directory
cd "$(dirname "$0")"

# Resolve Swift package dependencies
echo "Resolving Swift package dependencies..."
if [ -f "Kapal-Lawd.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved" ]; then
    echo "Package.resolved already exists."
else
    echo "Resolving packages..."
    xcodebuild -resolvePackageDependencies -project Kapal-Lawd.xcodeproj
fi

# Set up any environment variables needed for the build
export DEVELOPMENT_TEAM="U5CZ6K98KV"  # Replace with your actual team ID