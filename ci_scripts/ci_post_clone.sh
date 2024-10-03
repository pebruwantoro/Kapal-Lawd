#!/bin/bash

# Install XcodeGen if it's not already installed
if ! command -v xcodegen &> /dev/null; then
    echo "XcodeGen not found. Installing..."
    brew install xcodegen
fi

ls .

# Change to the project directory
cd ..

# Fetch the latest Git tag (should be a semantic version like 1.0.0)
GIT_TAG=$(git describe --tags $(git rev-list --tags --max-count=1))
echo "GIT_TAG: $GIT_TAG"

# Extract the numeric part of the tag (for MARKETING_VERSION, should be numeric like 1.0.0)
VERSION=$(echo $GIT_TAG | grep -oE '[0-9]+(\.[0-9]+)*')

# If no valid tag is found, default to 1.0.0
if [ -z "$VERSION" ]; then
  VERSION="1.0.0"
fi
echo "GIT_TAG: $GIT_TAG"

# If the tag contains non-numeric parts (e.g., alpha-1.1.2), use the commit count as the build number
if [[ $GIT_TAG =~ [^0-9.] ]]; then
  # Set CURRENT_PROJECT_VERSION as the number of commits
  BUILD_NUMBER=$(git rev-list --count HEAD)
else
  # If the tag is purely numeric, use the tag as the CURRENT_PROJECT_VERSION
  BUILD_NUMBER=$VERSION
fi
echo "GIT_TAG: $BUILD_NUMBER"

# Export variables to be used in xcodegen
export MARKETING_VERSION=$VERSION
export CURRENT_PROJECT_VERSION=$BUILD_NUMBER

echo "MARKETING_VERSION: $MARKETING_VERSION"
echo "CURRENT_PROJECT_VERSION: $CURRENT_PROJECT_VERSION"

# Generate the Xcode project using XcodeGen
echo "Generating Xcode project..."
xcodegen

echo "Check file on Kapal-Lawd.xcodeproj"
ls Kapal-Lawd.xcodeproj

echo "Check file on project.xcworkspace"
ls Kapal-Lawd.xcodeproj/project.xcworkspace 

echo "Check file on xcshareddata"
ls Kapal-Lawd.xcodeproj/project.xcworkspace/xcshareddata

mkdir Kapal-Lawd.xcodeproj/project.xcworkspace/xcshareddata

mkdir Kapal-Lawd.xcodeproj/project.xcworkspace/xcshareddata/swiftpm

touch Kapal-Lawd.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved

echo "Creating Package.resolved..."
cat <<EOL > Kapal-Lawd.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
{
  "originHash" : "fc9f608b2604b47e8a4e8f6d34706a07df80b7a48044b46fc831990fd3c8aece",
  "pins" : [
    {
      "identity" : "sdbeaconscanner",
      "kind" : "remoteSourceControl",
      "location" : "https://github.com/SagarSDagdu/SDBeaconScanner.git",
      "state" : {
        "revision" : "1b9ce5a1ba30691f7c4d404e6efd8c9ed02c230e",
        "version" : "0.0.2"
      }
    }
  ],
  "version" : 3
}
EOL

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
