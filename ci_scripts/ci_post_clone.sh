#!/bin/sh

brew update

# Install Xcodegen
brew install xcodegen

# Go to Project Directory
cd ..

# Generate the Xcode project
xcodegen generate

# mkdir -p Kapal-Lawd.xcodeproj/project.xcworkspace/xcshareddata/swiftpm

# ls -la
# ls $(pwd)/Kapal-Lawd.xcodeproj/project.xcworkspace/xcshareddata/swiftpm
# cat $(pwd)/Kapal-Lawd.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved


# # Resolve Swift package dependencies
# xcodebuild -project Kapal-Lawd.xcodeproj -scheme Kapal-Lawd -resolvePackageDependencies -verbose
