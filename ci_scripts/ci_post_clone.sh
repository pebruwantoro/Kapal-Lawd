#!/bin/sh

brew install xcodegen

cd ..

xcodegen generate

xcodebuild -resolvePackageDependencies -project Kapal-Lawd.xcodeproj