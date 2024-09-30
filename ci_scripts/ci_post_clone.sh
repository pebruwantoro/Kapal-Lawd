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

# Any other post-clone setup tasks can be added here
# Navigate to the project directory
cd Kapal-Lawd.xcodeproj

# Create the xcshareddata/swiftpm directory if it doesn't exist
mkdir -p project.xcworkspace/xcshareddata/swiftpm

