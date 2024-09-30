#!/bin/bash

# Change to the project directory
cd ..

# Install XcodeGen if it's not already installed
if ! command -v xcodegen &> /dev/null; then
    echo "XcodeGen not found. Installing..."
    brew install xcodegen
fi

# Generate the Xcode project using XcodeGen
echo "Generating Xcode project..."
xcodegen

# Navigate to the project directory
cd Kapal-Lawd.xcodeproj

# Create the xcshareddata/swiftpm directory if it doesn't exist
mkdir -p project.xcworkspace/xcshareddata/swiftpm

# Resolve package dependencies to generate Package.resolved
echo "Resolving package dependencies..."
xcodebuild -resolvePackageDependencies -project Kapal-Lawd.xcodeproj -scheme Kapal-Lawd

# Check if Package.resolved was created
if [ -f "project.xcworkspace/xcshareddata/swiftpm/Package.resolved" ]; then
    echo "Package.resolved generated successfully."
else
    echo "Failed to generate Package.resolved."
    exit 1
fi

# List files to verify the structure
ls -la project.xcworkspace/xcshareddata/swiftpm
