#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Change to the project directory
cd "$(dirname "$0")"

# Check if the build succeeded
if [ $? -eq 0 ]; then
    echo "Build succeeded!"
    # You can add deployment or notification scripts here
else
    echo "Build failed!"
    exit 1
fi