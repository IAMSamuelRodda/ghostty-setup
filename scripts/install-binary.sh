#!/bin/bash
# Ghostty Setup - Binary Installation Script
# Quick install for Ubuntu 24.04/25.04 x86_64
# This script installs the pre-built Ghostty binary and configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Ghostty Quick Install (Binary)${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to print step
print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

# Function to print success
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Function to print error
print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Step 1: System compatibility check
print_step "Checking system compatibility..."

# Check architecture
ARCH=$(uname -m)
if [ "$ARCH" != "x86_64" ]; then
    print_error "This binary is for x86_64 architecture only. Found: $ARCH"
    echo "Please use the source installation method instead:"
    echo "./scripts/install-from-source.sh"
    exit 1
fi

# Check OS
if [ ! -f /etc/os-release ]; then
    print_warning "Cannot detect OS. Proceeding anyway..."
else
    source /etc/os-release
    if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
        print_warning "This binary is built for Ubuntu/Debian. Your OS: $ID"
        echo "The installation may work but is not guaranteed."
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
fi

print_success "System compatibility check passed"
echo ""

# Step 2: Check for existing Ghostty installation
print_step "Checking for existing Ghostty installation..."

if [ -f "$HOME/.local/bin/ghostty" ]; then
    print_warning "Ghostty is already installed at ~/.local/bin/ghostty"
    CURRENT_VERSION=$("$HOME/.local/bin/ghostty" --version 2>&1 | head -1 || echo "unknown")
    echo "Current version: $CURRENT_VERSION"
    read -p "Overwrite existing installation? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
fi

if [ -d "$HOME/.config/ghostty" ]; then
    print_warning "Ghostty config exists at ~/.config/ghostty"
    read -p "Backup and replace existing config? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        BACKUP_DIR="$HOME/.config/ghostty.backup.$(date +%Y%m%d_%H%M%S)"
        cp -r "$HOME/.config/ghostty" "$BACKUP_DIR"
        print_success "Backed up existing config to: $BACKUP_DIR"
    else
        SKIP_CONFIG=true
        print_warning "Skipping config installation"
    fi
fi

echo ""

# Step 3: Install runtime dependencies
print_step "Checking runtime dependencies..."

MISSING_DEPS=()

# Check for GTK4 libraries
if ! dpkg -l | grep -q "libgtk-4-1"; then
    MISSING_DEPS+=("libgtk-4-1")
fi

if ! dpkg -l | grep -q "libadwaita-1-0"; then
    MISSING_DEPS+=("libadwaita-1-0")
fi

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    print_warning "Missing runtime dependencies: ${MISSING_DEPS[*]}"
    echo "Installing runtime dependencies..."
    sudo apt update
    sudo apt install -y "${MISSING_DEPS[@]}"
    print_success "Runtime dependencies installed"
else
    print_success "All runtime dependencies are already installed"
fi

echo ""

# Step 4: Install Ghostty binary
print_step "Installing Ghostty binary..."

mkdir -p "$HOME/.local/bin"
cp "$REPO_ROOT/bin/ghostty-x86_64-linux" "$HOME/.local/bin/ghostty"
chmod +x "$HOME/.local/bin/ghostty"

print_success "Ghostty binary installed to ~/.local/bin/ghostty"

# Verify installation
INSTALLED_VERSION=$("$HOME/.local/bin/ghostty" --version 2>&1 | head -1 || echo "unknown")
echo "   Version: $INSTALLED_VERSION"
echo ""

# Step 5: Install configuration
if [ "$SKIP_CONFIG" != true ]; then
    print_step "Installing Ghostty configuration..."

    mkdir -p "$HOME/.config/ghostty"
    cp "$REPO_ROOT/config/config" "$HOME/.config/ghostty/"
    cp -r "$REPO_ROOT/config/themes" "$HOME/.config/ghostty/"

    print_success "Configuration installed to ~/.config/ghostty/"
    echo "   - Main config: ~/.config/ghostty/config"
    echo "   - Themes: ~/.config/ghostty/themes/"
else
    print_warning "Skipped config installation (keeping existing config)"
fi

echo ""

# Step 6: Install theme switcher script
print_step "Installing theme switcher script..."

cp "$REPO_ROOT/scripts/switch-theme.sh" "$HOME/.config/ghostty/"
chmod +x "$HOME/.config/ghostty/switch-theme.sh"

print_success "Theme switcher installed to ~/.config/ghostty/switch-theme.sh"
echo ""

# Step 7: Verify PATH
print_step "Verifying PATH configuration..."

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    print_warning "~/.local/bin is not in your PATH"
    echo ""
    echo "Add this line to your ~/.bashrc or ~/.zshrc:"
    echo ""
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
    echo "Then reload your shell:"
    echo "    source ~/.bashrc"
else
    print_success "~/.local/bin is in your PATH"
fi

echo ""

# Step 8: Offer optional installations
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Optional Components${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

read -p "Install JetBrains Mono font? (Y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    "$SCRIPT_DIR/install-fonts.sh"
fi

echo ""
read -p "Install Matrix rain effects? (Y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    "$SCRIPT_DIR/install-matrix-tools.sh"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Open a new terminal or run: source ~/.bashrc"
echo "  2. Launch Ghostty: ghostty"
echo "  3. Switch themes: ~/.config/ghostty/switch-theme.sh"
echo ""
echo "Available themes:"
echo "  - matrix-dramatic  (current default)"
echo "  - default-dark"
echo ""
echo "Enjoy your new terminal!"
