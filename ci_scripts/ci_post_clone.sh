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
