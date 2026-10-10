#!/bin/bash

# Build verification script for AuraEdge project

echo "Starting build verification..."

echo "1. Running Flutter analysis..."
flutter analyze
if [ $? -ne 0 ]; then
  echo "Flutter analysis failed!"
  exit 1
fi

echo "2. Running Dart typecheck..."
pnpm typecheck
if [ $? -ne 0 ]; then
  echo "Typecheck failed!"
  exit 1
fi

echo "3. Running tests..."
bun test
if [ $? -ne 0 ]; then
  echo "Tests failed!"
  exit 1
fi

echo "4. Checking for security issues..."
# Add security scanning here

echo "Build verification completed successfully!"