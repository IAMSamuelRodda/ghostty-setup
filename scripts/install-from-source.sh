#!/bin/bash
# Ghostty Setup - Source Installation Script
# Builds and installs Ghostty from official source releases

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
echo -e "${BLUE}  Ghostty Source Installation${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "This script will:"
echo "  1. Check/install build dependencies"
echo "  2. Download Ghostty source (latest or specific version)"
echo "  3. Build Ghostty from source (~10-20 minutes)"
echo "  4. Install Ghostty binary"
echo "  5. Deploy configuration files"
echo ""
read -p "Continue? (Y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
    exit 0
fi
echo ""

# Step 1: Check dependencies
print_step "Step 1/8: Checking build dependencies..."

MISSING_DEPS=()

# Check Zig
if ! command -v zig &> /dev/null; then
    MISSING_DEPS+=("zig")
else
    ZIG_VERSION=$(zig version 2>&1)
    if [[ "$ZIG_VERSION" != "0.14.1" ]]; then
        print_warning "Zig version mismatch: $ZIG_VERSION (need 0.14.1)"
        MISSING_DEPS+=("zig")
    else
        print_success "Zig 0.14.1 found"
    fi
fi

# Check GTK4
if ! dpkg -l | grep -q "libgtk-4-dev"; then
    MISSING_DEPS+=("libgtk-4-dev")
else
    print_success "GTK4 development libraries found"
fi

# Check blueprint-compiler
if ! command -v blueprint-compiler &> /dev/null; then
    MISSING_DEPS+=("blueprint-compiler")
else
    BP_VERSION=$(blueprint-compiler --version 2>&1 | grep -oP '\d+\.\d+\.\d+' || echo "0.0.0")
    if [[ "$BP_VERSION" < "0.16.0" ]]; then
        print_warning "blueprint-compiler $BP_VERSION may be too old (need 0.16.0+)"
        MISSING_DEPS+=("blueprint-compiler")
    else
        print_success "blueprint-compiler $BP_VERSION found"
    fi
fi

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo ""
    print_warning "Missing or outdated dependencies: ${MISSING_DEPS[*]}"
    echo ""
    read -p "Install dependencies now? (Y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        "$SCRIPT_DIR/install-dependencies.sh"
    else
        print_error "Cannot proceed without dependencies"
        exit 1
    fi
else
    print_success "All build dependencies are installed"
fi

echo ""

# Step 2: Choose Ghostty version
print_step "Step 2/8: Choose Ghostty version to build..."
echo ""
echo "Options:"
echo "  1. Latest stable release (recommended)"
echo "  2. Specific version (e.g., 1.2.0)"
echo "  3. Development tip (bleeding edge)"
echo ""
read -p "Enter choice [1-3]: " -n 1 -r
echo ""

case $REPLY in
    1)
        GHOSTTY_VERSION="1.2.0"
        SOURCE_TYPE="release"
        ;;
    2)
        echo ""
        read -p "Enter version (e.g., 1.2.0): " GHOSTTY_VERSION
        SOURCE_TYPE="release"
        ;;
    3)
        print_warning "Development builds may be unstable"
        SOURCE_TYPE="git"
        ;;
    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

echo ""

# Step 3: Download source
if [ "$SOURCE_TYPE" = "release" ]; then
    print_step "Step 3/8: Downloading Ghostty ${GHOSTTY_VERSION} source..."

    BUILD_DIR="$HOME/ghostty-build"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    TARBALL="ghostty-${GHOSTTY_VERSION}.tar.gz"
    DOWNLOAD_URL="https://release.files.ghostty.org/${GHOSTTY_VERSION}/${TARBALL}"

    echo "   URL: $DOWNLOAD_URL"

    if [ -f "$TARBALL" ]; then
        print_warning "Source tarball already exists"
        read -p "Re-download? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -f "$TARBALL"
        fi
    fi

    if [ ! -f "$TARBALL" ]; then
        if ! curl -LO "$DOWNLOAD_URL"; then
            print_error "Download failed. Check if version ${GHOSTTY_VERSION} exists."
            echo "   Try https://ghostty.org/download for available versions"
            exit 1
        fi
    fi

    print_success "Source downloaded: $TARBALL"

    print_step "Extracting source..."
    rm -rf "ghostty-${GHOSTTY_VERSION}"
    tar -xzf "$TARBALL"

    SOURCE_DIR="$BUILD_DIR/ghostty-${GHOSTTY_VERSION}"

else
    # Git clone
    print_step "Step 3/8: Cloning Ghostty development repository..."

    BUILD_DIR="$HOME/ghostty-build"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    if [ -d "ghostty" ]; then
        print_warning "Git repository already exists"
        cd ghostty
        git pull
        cd ..
    else
        git clone https://github.com/ghostty-org/ghostty.git
    fi

    SOURCE_DIR="$BUILD_DIR/ghostty"
fi

print_success "Source ready at: $SOURCE_DIR"
echo ""

# Step 4: Configure build
print_step "Step 4/8: Configuring build..."

cd "$SOURCE_DIR"

# Check if gtk4-layer-shell is available
BUILD_FLAGS="-Doptimize=ReleaseFast"

if ! apt-cache show libgtk4-layer-shell-dev &>/dev/null; then
    print_warning "libgtk4-layer-shell not in repos, will compile from source"
    BUILD_FLAGS="$BUILD_FLAGS -Dno-sys=gtk4-layer-shell"
fi

echo "   Build flags: $BUILD_FLAGS"
print_success "Build configured"
echo ""

# Step 5: Build Ghostty
print_step "Step 5/8: Building Ghostty (this may take 10-20 minutes)..."
echo ""
echo "   Build command: zig build $BUILD_FLAGS"
echo ""
print_warning "This will use CPU/RAM. Go grab a coffee!"
echo ""

# Show progress
if ! zig build $BUILD_FLAGS; then
    print_error "Build failed"
    echo ""
    echo "Common issues:"
    echo "  - Zig version mismatch (need exactly 0.14.1)"
    echo "  - Missing dependencies"
    echo "  - Insufficient memory (needs ~4GB)"
    echo ""
    echo "Build log saved at: $SOURCE_DIR"
    exit 1
fi

print_success "Build completed successfully!"
echo ""

# Step 6: Verify binary
print_step "Step 6/8: Verifying built binary..."

if [ ! -f "zig-out/bin/ghostty" ]; then
    print_error "Binary not found at zig-out/bin/ghostty"
    exit 1
fi

BUILT_VERSION=$(zig-out/bin/ghostty --version 2>&1 | head -1)
print_success "Built version: $BUILT_VERSION"
echo ""

# Step 7: Install binary
print_step "Step 7/8: Installing Ghostty binary..."

echo "Choose installation location:"
echo "  1. User install (~/.local/bin) - recommended, no sudo"
echo "  2. System install (/usr/local/bin) - requires sudo"
echo ""
read -p "Enter choice [1-2]: " -n 1 -r
echo ""

case $REPLY in
    1)
        INSTALL_PREFIX="$HOME/.local"
        print_step "Installing to $INSTALL_PREFIX..."
        zig build -p "$INSTALL_PREFIX" $BUILD_FLAGS
        BINARY_PATH="$HOME/.local/bin/ghostty"
        ;;
    2)
        INSTALL_PREFIX="/usr/local"
        print_step "Installing to $INSTALL_PREFIX (requires sudo)..."
        sudo zig build -p "$INSTALL_PREFIX" $BUILD_FLAGS
        BINARY_PATH="/usr/local/bin/ghostty"
        ;;
    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

if [ -f "$BINARY_PATH" ]; then
    INSTALLED_VERSION=$("$BINARY_PATH" --version 2>&1 | head -1)
    print_success "Ghostty installed successfully!"
    echo "   Location: $BINARY_PATH"
    echo "   Version: $INSTALLED_VERSION"
else
    print_error "Installation verification failed"
    exit 1
fi

echo ""

# Step 8: Install configuration
print_step "Step 8/8: Installing configuration files..."

if [ -d "$HOME/.config/ghostty" ]; then
    print_warning "Configuration already exists at ~/.config/ghostty"
    read -p "Backup and replace? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        BACKUP_DIR="$HOME/.config/ghostty.backup.$(date +%Y%m%d_%H%M%S)"
        cp -r "$HOME/.config/ghostty" "$BACKUP_DIR"
        print_success "Backed up to: $BACKUP_DIR"
    else
        print_warning "Skipping config installation"
        SKIP_CONFIG=true
    fi
fi

if [ "$SKIP_CONFIG" != true ]; then
    mkdir -p "$HOME/.config/ghostty"
    cp "$REPO_ROOT/config/config" "$HOME/.config/ghostty/"
    cp -r "$REPO_ROOT/config/themes" "$HOME/.config/ghostty/"
    cp "$REPO_ROOT/scripts/switch-theme.sh" "$HOME/.config/ghostty/"
    chmod +x "$HOME/.config/ghostty/switch-theme.sh"

    print_success "Configuration installed"
    echo "   Config: ~/.config/ghostty/config"
    echo "   Themes: ~/.config/ghostty/themes/"
fi

echo ""

# Optional cleanup
print_step "Cleanup build files?"
echo "Build directory: $BUILD_DIR"
du -sh "$BUILD_DIR" 2>/dev/null || echo "Unknown size"
echo ""
read -p "Remove build directory to save space? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$BUILD_DIR"
    print_success "Build directory removed"
else
    echo "Build directory kept at: $BUILD_DIR"
    echo "You can rebuild with: cd $SOURCE_DIR && zig build $BUILD_FLAGS"
fi

echo ""

# Verify PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && [ "$INSTALL_PREFIX" = "$HOME/.local" ]; then
    print_warning "~/.local/bin is not in your PATH"
    echo ""
    echo "Add this to your ~/.bashrc or ~/.zshrc:"
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
fi

echo ""

# Optional installations
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
echo "Ghostty has been built and installed from source!"
echo ""
echo "Next steps:"
echo "  1. Open a new terminal or run: source ~/.bashrc"
echo "  2. Launch Ghostty: ghostty"
echo "  3. Switch themes: ~/.config/ghostty/switch-theme.sh"
echo ""
echo "Enjoy your freshly compiled terminal!"
