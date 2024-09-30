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

chmod 775 Kapal-Lawd.xcodeproj
sudo chown -R tc:tc Kapal-Lawd.xcodeproj

echo "Current Directory: $(pwd)"
ls -la

echo "TEST echo: $(./Kapal-Lawd.xcodeproj/project.xcworkspace/xcshareddata/swiftpm)"

# Check if Package.resolved exists
if [ ! -f "./Kapal-Lawd.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved" ]; then
    echo "Package.resolved not found. Generating it..."
    xcodebuild -resolvePackageDependencies -project ./Kapal-Lawd.xcodeproj -scheme Kapal-Lawd
fi

# Resolve package dependencies
#xcodebuild -resolvePackageDependencies -project ./Kapal-Lawd.xcodeproj -scheme Kapal-Lawd
xcodebuild -resolvePackageDependencies -project ./Kapal-Lawd.xcodeproj -scheme Kapal-Lawd -allowProvisioningUpdates

# Build the project
xcodebuild -project ./Kapal-Lawd.xcodeproj -scheme Kapal-Lawd -verbose

# Confirm resolution status
if [ $? -ne 0 ]; then
    echo "Failed to resolve package dependencies."
    exit 1
fi

# List project contents
ls
