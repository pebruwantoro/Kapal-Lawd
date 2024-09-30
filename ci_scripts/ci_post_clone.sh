#!/bin/bash

# Install XcodeGen if it's not already installed
if ! command -v xcodegen &> /dev/null; then
    echo "XcodeGen not found. Installing..."
    brew install xcodegen
fi

ls .

# Change to the project directory
cd ..

# Generate the Xcode project using XcodeGen
echo "Generating Xcode project..."
xcodegen

ls Kapal-Lawd.xcodeproj

mkdir Kapal-Lawd.xcodeproj/project.xcworkspace

ls Kapal-Lawd.xcodeproj/project.xcworkspace 

mkdir Kapal-Lawd.xcodeproj/project.xcworkspace/xcshareddata

ls Kapal-Lawd.xcodeproj/project.xcworkspace/xcshareddata

mkdir Kapal-Lawd.xcodeproj/project.xcworkspace/xcshareddata/swiftpm

touch Kapal-Lawd.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved

# Resolve package dependencies to generate Package.resolved
echo "Resolving package dependencies..."
xcodebuild -resolvePackageDependencies -project Kapal-Lawd.xcodeproj -scheme Kapal-Lawd

# Check if Package.resolved was created
if [ -f "Kapal-Lawd.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved" ]; then
    echo "Package.resolved generated successfully."
else
    echo "Failed to generate Package.resolved."
    exit 1
fi
