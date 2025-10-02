#!/bin/bash

# DripLix Web Runner Script
echo "Starting DripLix web application..."
echo "Make sure you have Flutter installed and Chrome browser available."
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

# Run the web app
echo "Starting web server on http://localhost:8080"
echo "Press Ctrl+C to stop the server"
echo ""
flutter run -d chrome --web-port=8080
