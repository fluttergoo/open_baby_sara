#!/bin/bash

# CI/CD Setup Helper Script
# This script helps you verify your CI/CD setup locally before pushing to GitHub

set -e

echo "🚀 Sara Baby Tracker - CI/CD Setup Verification"
echo "=============================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "ℹ $1"
}

# Check Flutter installation
echo "Checking Flutter installation..."
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    print_success "Flutter is installed: $FLUTTER_VERSION"
else
    print_error "Flutter is not installed"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check Flutter version
echo ""
echo "Checking Flutter version compatibility..."
CURRENT_VERSION=$(flutter --version | grep -oP 'Flutter \K[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
REQUIRED_VERSION="3.27.1"
print_info "Current: $CURRENT_VERSION, Required: $REQUIRED_VERSION"
print_warning "Make sure your Flutter version is compatible"

# Check Java installation (for Android)
echo ""
echo "Checking Java installation..."
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1)
    print_success "Java is installed: $JAVA_VERSION"
else
    print_error "Java is not installed"
    echo "Please install Java 17 for Android builds"
fi

# Check Ruby installation (for iOS)
echo ""
echo "Checking Ruby installation (for iOS)..."
if command -v ruby &> /dev/null; then
    RUBY_VERSION=$(ruby --version)
    print_success "Ruby is installed: $RUBY_VERSION"
else
    print_warning "Ruby is not installed (needed for iOS fastlane)"
fi

# Check Fastlane installation (for iOS)
echo ""
echo "Checking Fastlane installation (for iOS)..."
if command -v fastlane &> /dev/null; then
    FASTLANE_VERSION=$(fastlane --version | head -n 1)
    print_success "Fastlane is installed: $FASTLANE_VERSION"
else
    print_warning "Fastlane is not installed (needed for iOS deployment)"
    echo "Install with: sudo gem install fastlane"
fi

# Check CocoaPods installation (for iOS)
echo ""
echo "Checking CocoaPods installation (for iOS)..."
if command -v pod &> /dev/null; then
    POD_VERSION=$(pod --version)
    print_success "CocoaPods is installed: $POD_VERSION"
else
    print_warning "CocoaPods is not installed (needed for iOS builds)"
    echo "Install with: sudo gem install cocoapods"
fi

# Check project structure
echo ""
echo "Checking project structure..."

if [ -f "pubspec.yaml" ]; then
    print_success "pubspec.yaml found"
    VERSION=$(grep "version:" pubspec.yaml | awk '{print $2}')
    print_info "Current app version: $VERSION"
else
    print_error "pubspec.yaml not found"
    exit 1
fi

if [ -d "android" ]; then
    print_success "Android directory found"
else
    print_error "Android directory not found"
fi

if [ -d "ios" ]; then
    print_success "iOS directory found"
else
    print_error "iOS directory not found"
fi

# Check Android configuration
echo ""
echo "Checking Android configuration..."

if [ -f "android/app/build.gradle.kts" ]; then
    print_success "Android build.gradle.kts found"
else
    print_error "android/app/build.gradle.kts not found"
fi

if [ -f "android/app/google-services.json" ]; then
    print_success "google-services.json found"
else
    print_warning "google-services.json not found (needed for Firebase)"
fi

if [ -f "android/key.properties" ]; then
    print_success "key.properties found (for release signing)"
    print_warning "Make sure key.properties is in .gitignore"
else
    print_warning "key.properties not found (needed for release builds)"
    echo "Create it with:"
    echo "  storePassword=your_password"
    echo "  keyPassword=your_password"
    echo "  keyAlias=your_alias"
    echo "  storeFile=your_keystore.jks"
fi

# Check iOS configuration
echo ""
echo "Checking iOS configuration..."

if [ -f "ios/Podfile" ]; then
    print_success "Podfile found"
else
    print_error "ios/Podfile not found"
fi

if [ -d "ios/Runner.xcworkspace" ]; then
    print_success "Runner.xcworkspace found"
else
    print_warning "Runner.xcworkspace not found (run 'pod install' in ios directory)"
fi

if [ -f "ios/fastlane/Fastfile" ]; then
    print_success "Fastfile found"
else
    print_error "ios/fastlane/Fastfile not found"
fi

# Check GitHub Actions workflow
echo ""
echo "Checking GitHub Actions workflow..."

if [ -f ".github/workflows/ci_cd.yml" ]; then
    print_success "CI/CD workflow file found"
else
    print_error ".github/workflows/ci_cd.yml not found"
fi

# Test Flutter build
echo ""
echo "Testing Flutter build..."
print_info "Running flutter pub get..."
if flutter pub get; then
    print_success "Dependencies installed successfully"
else
    print_error "Failed to install dependencies"
    exit 1
fi

echo ""
print_info "Running flutter analyze..."
if flutter analyze; then
    print_success "Code analysis passed"
else
    print_warning "Code analysis found issues (warnings are acceptable in CI/CD)"
fi

echo ""
print_info "Running flutter test..."
if flutter test; then
    print_success "Tests passed"
else
    print_error "Tests failed"
    exit 1
fi

# Summary
echo ""
echo "=============================================="
echo "✅ CI/CD Setup Verification Complete!"
echo "=============================================="
echo ""
echo "Next steps:"
echo "1. Configure GitHub Secrets (see CI_CD_SETUP.md)"
echo "2. Push your code to trigger the CI/CD pipeline"
echo "3. Monitor the workflow in GitHub Actions tab"
echo ""
echo "For detailed setup instructions, see:"
echo "  - CI_CD_SETUP.md"
echo "  - REQUIRED_SECRETS.md"
echo ""
echo "Happy coding! 🎉"

