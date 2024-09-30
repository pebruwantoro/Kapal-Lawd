#!/bin/sh

# Install Xcodegen
if ! command -v xcodegen &> /dev/null; then
    brew install xcodegen
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
