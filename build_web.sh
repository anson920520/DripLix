#!/bin/bash

# DripLix Web Build Script
echo "Building DripLix for web production..."
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "Error: Flutter is not installed or not in PATH"
    echo "Please install Flutter from https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Get dependencies
echo "Installing dependencies..."
flutter pub get

# Build for web
echo "Building web application..."
flutter build web --release

echo ""
echo "Build completed! Files are available in the 'build/web' directory."
echo "You can serve them using any web server or deploy to your hosting platform."
