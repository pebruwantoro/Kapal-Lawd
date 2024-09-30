#!/bin/sh

# Install Xcodegen
if ! command -v xcodegen &> /dev/null
then
    brew install xcodegen
fi

echo "Current Directory: $(pwd)"
ls -la

# Go to Project Directory
cd ..

echo "Current Directory: $(pwd)"
ls -la

# Generate the Xcode project
xcodegen generate

# See all project
echo "Current Directory: $(pwd)"
ls -la

# Check if the project was generated successfully
if [ ! -d "Kapal-Lawd.xcodeproj" ]; then
    echo "Failed to generate Xcode project."
    exit 1
fi

echo "Current Directory: $(pwd)"
ls -la

ls -la Kapal-Lawd.xcodeproj
ls -la Kapal-Lawd.xcodeproj/project.xcworkspace
ls -la Kapal-Lawd.xcodeproj/project.xcworkspace/xcshareddata
ls -la Kapal-Lawd.xcodeproj/project.xcworkspace/xcshareddata/swiftpm

# Resolve package dependencies
xcodebuild -resolvePackageDependencies -project ./Kapal-Lawd.xcodeproj -scheme Kapal-Lawd -allowProvisioningUpdates

# Build the project
xcodebuild -project ./Kapal-Lawd.xcodeproj -scheme Kapal-Lawd -verbose

# Confirm resolution status
if [ $? -ne 0 ]; then
    echo "Failed to resolve package dependencies."
    exit 1
fi
