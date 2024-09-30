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

echo "Check file on Kapal-Lawd.xcodeproj"
ls Kapal-Lawd.xcodeproj

echo "Check file on project.xcworkspace"
ls Kapal-Lawd.xcodeproj/project.xcworkspace 

# mkdir Kapal-Lawd.xcodeproj/project.xcworkspace/xcshareddata

echo "Check file on xcshareddata"
ls Kapal-Lawd.xcodeproj/project.xcworkspace/xcshareddata

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
