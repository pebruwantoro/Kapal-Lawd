#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Change to the project directory
cd "$(dirname "$0")"

# Install XcodeGen if it's not already installed
if ! command -v xcodegen &> /dev/null; then
    echo "XcodeGen not found. Installing..."
    brew install xcodegen
fi

# Generate the Xcode project using XcodeGen
echo "Generating Xcode project..."
xcodegen

# Any other post-clone setup tasks can be added here