#!/bin/bash

# Install XcodeGen if it's not already installed
if ! command -v xcodegen &> /dev/null; then
    echo "XcodeGen not found. Installing..."
    brew install xcodegen
fi
if ! command -v xmlstarlet &> /dev/null; then
    echo "xmlstarlet not found. Installing..."
    brew install xmlstarlet
fi
ls .

# Change to the project directory
cd ..

# Fetch the latest Git tag (should be a semantic version like 1.0.0)
git fetch --tags
GIT_TAG=$(git describe --tags $(git rev-list --tags --max-count=1))
echo "GIT_TAG: $GIT_TAG"

# Extract the numeric part of the tag (for MARKETING_VERSION, should be numeric like 1.0.0)
VERSION=$(echo $GIT_TAG | grep -oE '[0-9]+(\.[0-9]+)*')

# If no valid tag is found, default to 1.0.0
if [ -z "$VERSION" ]; then
  VERSION="1.0.0"
fi
echo "VERSION: $VERSION"

# If the tag contains non-numeric parts (e.g., alpha-1.1.2), use the commit count as the build number
if [[ $GIT_TAG =~ [^0-9.] ]]; then
  # Set CURRENT_PROJECT_VERSION as the number of commits
  BUILD_NUMBER=$(git rev-list --count HEAD)
else
  # If the tag is purely numeric, use the tag as the CURRENT_PROJECT_VERSION
  BUILD_NUMBER=$VERSION
fi
echo "BUILD_NUMBER: $BUILD_NUMBER"

# Export variables to be used in xcodegen
export MARKETING_VERSION=$VERSION
export CURRENT_PROJECT_VERSION=$BUILD_NUMBER
export SUPABASE_API_KEY=$SUPABASE_API_KEY
export SUPABASE_BASE_URL=$SUPABASE_BASE_URL
export SCHEME_PATH=$SCHEME_PATH

echo "MARKETING_VERSION: $MARKETING_VERSION"
echo "CURRENT_PROJECT_VERSION: $CURRENT_PROJECT_VERSION"
echo "SUPABASE_API_KEY: $SUPABASE_API_KEY"
echo "SUPABASE_BASE_URL: $SUPABASE_BASE_URL"
echo "SCHEME_PATH: $SCHEME_PATH"

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
  "originHash" : "04c19fbbf2e3b911933c8c85d19cf193e0a802c75b5cad57a6af6f3faf87e10e",
  "pins" : [
    {
      "identity" : "sdbeaconscanner",
      "kind" : "remoteSourceControl",
      "location" : "https://github.com/SagarSDagdu/SDBeaconScanner.git",
      "state" : {
        "revision" : "1b9ce5a1ba30691f7c4d404e6efd8c9ed02c230e",
        "version" : "0.0.2"
      }
    },
    {
      "identity" : "supabase-swift",
      "kind" : "remoteSourceControl",
      "location" : "https://github.com/supabase/supabase-swift.git",
      "state" : {
        "revision" : "24c6b2252f35cdd45e546bb5ea2c684c963df726",
        "version" : "2.20.5"
      }
    },
    {
      "identity" : "swift-asn1",
      "kind" : "remoteSourceControl",
      "location" : "https://github.com/apple/swift-asn1.git",
      "state" : {
        "revision" : "7faebca1ea4f9aaf0cda1cef7c43aecd2311ddf6",
        "version" : "1.3.0"
      }
    },
    {
      "identity" : "swift-concurrency-extras",
      "kind" : "remoteSourceControl",
      "location" : "https://github.com/pointfreeco/swift-concurrency-extras",
      "state" : {
        "revision" : "6054df64b55186f08b6d0fd87152081b8ad8d613",
        "version" : "1.2.0"
      }
    },
    {
      "identity" : "swift-crypto",
      "kind" : "remoteSourceControl",
      "location" : "https://github.com/apple/swift-crypto.git",
      "state" : {
        "revision" : "8fa345c2081cfbd4851dffff5dd5bed48efe6081",
        "version" : "3.9.0"
      }
    },
    {
      "identity" : "swift-http-types",
      "kind" : "remoteSourceControl",
      "location" : "https://github.com/apple/swift-http-types.git",
      "state" : {
        "revision" : "ae67c8178eb46944fd85e4dc6dd970e1f3ed6ccd",
        "version" : "1.3.0"
      }
    },
    {
      "identity" : "xctest-dynamic-overlay",
      "kind" : "remoteSourceControl",
      "location" : "https://github.com/pointfreeco/xctest-dynamic-overlay",
      "state" : {
        "revision" : "770f990d3e4eececb57ac04a6076e22f8c97daeb",
        "version" : "1.4.2"
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

if [ -f "Kapal-Lawd/Info.plist" ]; then
    echo "Info.plist file found."
    cat Kapal-Lawd/Info.plist
else
    echo "Info.plist file not found."
    exit 1
fi