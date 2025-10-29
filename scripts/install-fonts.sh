#!/bin/bash
# Ghostty Setup - Font Installation Script
# Installs JetBrains Mono font for optimal terminal experience

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  JetBrains Mono Font Installation${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if already installed
if fc-list | grep -qi "jetbrains.*mono"; then
    print_success "JetBrains Mono is already installed"
    fc-list | grep -i "jetbrains.*mono" | head -3
    echo ""
    read -p "Reinstall anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Font installation skipped."
        exit 0
    fi
fi

echo ""
echo "Choose installation method:"
echo "  1. Install from Ubuntu repositories (recommended, easy)"
echo "  2. Download latest from JetBrains GitHub (latest version)"
echo "  3. Skip font installation"
echo ""
read -p "Enter choice [1-3]: " -n 1 -r
echo ""
echo ""

case $REPLY in
    1)
        print_step "Installing JetBrains Mono from Ubuntu repositories..."

        # Check if fonts-jetbrains-mono package exists
        if apt-cache show fonts-jetbrains-mono &>/dev/null; then
            sudo apt update
            sudo apt install -y fonts-jetbrains-mono
            print_success "JetBrains Mono installed from repositories"
        else
            print_warning "fonts-jetbrains-mono package not found in repositories"
            echo "Falling back to manual installation..."
            REPLY=2
        fi
        ;;
    2)
        print_step "Downloading JetBrains Mono from GitHub..."

        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR"

        # Get latest release version
        LATEST_VERSION=$(curl -s https://api.github.com/repos/JetBrains/JetBrainsMono/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')

        if [ -z "$LATEST_VERSION" ]; then
            print_error "Failed to fetch latest version"
            echo "Using fallback version 2.304"
            LATEST_VERSION="2.304"
        fi

        echo "Latest version: $LATEST_VERSION"

        DOWNLOAD_URL="https://github.com/JetBrains/JetBrainsMono/releases/download/v${LATEST_VERSION}/JetBrainsMono-${LATEST_VERSION}.zip"

        print_step "Downloading from: $DOWNLOAD_URL"

        if ! curl -L -o JetBrainsMono.zip "$DOWNLOAD_URL"; then
            print_error "Download failed"
            cd - > /dev/null
            rm -rf "$TEMP_DIR"
            exit 1
        fi

        print_step "Extracting fonts..."
        unzip -q JetBrainsMono.zip

        print_step "Installing fonts to ~/.local/share/fonts/JetBrainsMono..."
        mkdir -p "$HOME/.local/share/fonts/JetBrainsMono"

        # Copy TTF files
        find . -name "*.ttf" -exec cp {} "$HOME/.local/share/fonts/JetBrainsMono/" \;

        # Update font cache
        print_step "Updating font cache..."
        fc-cache -f -v "$HOME/.local/share/fonts/JetBrainsMono" &>/dev/null

        # Clean up
        cd - > /dev/null
        rm -rf "$TEMP_DIR"

        print_success "JetBrains Mono installed successfully"
        ;;
    3)
        echo "Font installation skipped."
        exit 0
        ;;
    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

echo ""
print_step "Verifying installation..."

if fc-list | grep -qi "jetbrains.*mono"; then
    print_success "JetBrains Mono is now available"
    echo ""
    echo "Installed variants:"
    fc-list | grep -i "jetbrains.*mono" | sed 's/.*: /  - /' | sort -u | head -10
else
    print_error "Font installation verification failed"
    echo "You may need to restart your terminal or run: fc-cache -f -v"
fi

echo ""
print_success "Font installation complete!"
echo ""
echo "Note: You may need to restart Ghostty for the font to appear."
