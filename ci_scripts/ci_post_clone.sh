#!/bin/sh

# Install Xcodegen
if ! command -v xcodegen &> /dev/null
then
    brew install xcodegen
fi

# Go to Project Directory
cd ..

# Generate the Xcode project
xcodegen generate

# See all project
ls

# Check if the project was generated successfully
if [ ! -d "Kapal-Lawd.xcodeproj" ]; then
    echo "Failed to generate Xcode project."
    exit 1
fi

# Navigate to the project's directory (if needed)
cd Kapal-Lawd.xcodeproj

# Resolve package dependencies
xcodebuild -resolvePackageDependencies -project Kapal-Lawd.xcodeproj -scheme Kapal-Lawd -verbose

# Confirm resolution status
if [ $? -ne 0 ]; then
    echo "Failed to resolve package dependencies."
    exit 1
fi

# List project contents
ls
