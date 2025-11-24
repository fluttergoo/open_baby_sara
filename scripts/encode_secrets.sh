#!/bin/bash

# Secret Encoding Helper Script
# This script helps you encode secrets for GitHub Actions

set -e

echo "🔐 Secret Encoding Helper for GitHub Actions"
echo "============================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Function to encode Android keystore
encode_keystore() {
    echo ""
    print_info "Encoding Android Keystore"
    echo "Enter the path to your keystore file (e.g., android/app/my-release-key.jks):"
    read -r KEYSTORE_PATH
    
    if [ ! -f "$KEYSTORE_PATH" ]; then
        print_error "File not found: $KEYSTORE_PATH"
        return 1
    fi
    
    print_info "Encoding keystore to base64..."
    ENCODED=$(base64 -i "$KEYSTORE_PATH")
    
    echo ""
    print_success "Keystore encoded successfully!"
    echo ""
    echo "Add this to GitHub Secrets as KEYSTORE_BASE64:"
    echo "================================================"
    echo "$ENCODED"
    echo "================================================"
    echo ""
    
    # Copy to clipboard if available
    if command -v pbcopy &> /dev/null; then
        echo "$ENCODED" | pbcopy
        print_success "Copied to clipboard (macOS)!"
    elif command -v xclip &> /dev/null; then
        echo "$ENCODED" | xclip -selection clipboard
        print_success "Copied to clipboard (Linux)!"
    fi
}

# Function to encode iOS API Key
encode_ios_api_key() {
    echo ""
    print_info "Encoding iOS App Store Connect API Key"
    echo "Enter the path to your .p8 file (e.g., AuthKey_ABC123.p8):"
    read -r P8_PATH
    
    if [ ! -f "$P8_PATH" ]; then
        print_error "File not found: $P8_PATH"
        return 1
    fi
    
    print_info "Reading .p8 file..."
    P8_CONTENT=$(cat "$P8_PATH")
    
    echo ""
    print_success "API Key read successfully!"
    echo ""
    echo "Add this to GitHub Secrets as APP_STORE_CONNECT_API_KEY:"
    echo "========================================================"
    echo "$P8_CONTENT"
    echo "========================================================"
    echo ""
    
    # Extract Key ID from filename
    FILENAME=$(basename "$P8_PATH")
    KEY_ID=$(echo "$FILENAME" | sed -n 's/AuthKey_\(.*\)\.p8/\1/p')
    
    if [ -n "$KEY_ID" ]; then
        echo ""
        print_info "Detected Key ID: $KEY_ID"
        echo "Add this to GitHub Secrets as APP_STORE_CONNECT_API_KEY_ID:"
        echo "$KEY_ID"
    fi
    
    # Copy to clipboard if available
    if command -v pbcopy &> /dev/null; then
        echo "$P8_CONTENT" | pbcopy
        print_success "Copied to clipboard (macOS)!"
    elif command -v xclip &> /dev/null; then
        echo "$P8_CONTENT" | xclip -selection clipboard
        print_success "Copied to clipboard (Linux)!"
    fi
}

# Function to encode Google Play Service Account JSON
encode_google_play_json() {
    echo ""
    print_info "Encoding Google Play Service Account JSON"
    echo "Enter the path to your service account JSON file:"
    read -r JSON_PATH
    
    if [ ! -f "$JSON_PATH" ]; then
        print_error "File not found: $JSON_PATH"
        return 1
    fi
    
    print_info "Reading JSON file..."
    JSON_CONTENT=$(cat "$JSON_PATH")
    
    echo ""
    print_success "Service Account JSON read successfully!"
    echo ""
    echo "Add this to GitHub Secrets as GOOGLE_PLAY_SERVICE_ACCOUNT_JSON:"
    echo "==============================================================="
    echo "$JSON_CONTENT"
    echo "==============================================================="
    echo ""
    
    # Copy to clipboard if available
    if command -v pbcopy &> /dev/null; then
        echo "$JSON_CONTENT" | pbcopy
        print_success "Copied to clipboard (macOS)!"
    elif command -v xclip &> /dev/null; then
        echo "$JSON_CONTENT" | xclip -selection clipboard
        print_success "Copied to clipboard (Linux)!"
    fi
}

# Function to encode git credentials for Match
encode_git_credentials() {
    echo ""
    print_info "Encoding Git Credentials for Fastlane Match"
    echo "Enter your git username:"
    read -r GIT_USERNAME
    echo "Enter your git personal access token:"
    read -rs GIT_TOKEN
    echo ""
    
    CREDENTIALS="${GIT_USERNAME}:${GIT_TOKEN}"
    ENCODED=$(echo -n "$CREDENTIALS" | base64)
    
    echo ""
    print_success "Git credentials encoded successfully!"
    echo ""
    echo "Add this to GitHub Secrets as MATCH_GIT_BASIC_AUTHORIZATION:"
    echo "==========================================================="
    echo "$ENCODED"
    echo "==========================================================="
    echo ""
    
    # Copy to clipboard if available
    if command -v pbcopy &> /dev/null; then
        echo "$ENCODED" | pbcopy
        print_success "Copied to clipboard (macOS)!"
    elif command -v xclip &> /dev/null; then
        echo "$ENCODED" | xclip -selection clipboard
        print_success "Copied to clipboard (Linux)!"
    fi
}

# Main menu
while true; do
    echo ""
    echo "What would you like to encode?"
    echo "1. Android Keystore (KEYSTORE_BASE64)"
    echo "2. iOS API Key (APP_STORE_CONNECT_API_KEY)"
    echo "3. Google Play Service Account JSON"
    echo "4. Git Credentials for Fastlane Match"
    echo "5. Exit"
    echo ""
    echo -n "Enter your choice (1-5): "
    read -r CHOICE
    
    case $CHOICE in
        1)
            encode_keystore
            ;;
        2)
            encode_ios_api_key
            ;;
        3)
            encode_google_play_json
            ;;
        4)
            encode_git_credentials
            ;;
        5)
            echo ""
            print_success "Goodbye! 👋"
            exit 0
            ;;
        *)
            print_error "Invalid choice. Please enter 1-5."
            ;;
    esac
done

