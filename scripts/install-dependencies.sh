#!/bin/bash
# Ghostty Setup - Build Dependencies Installation
# Installs all required dependencies for building Ghostty from source

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
echo -e "${BLUE}  Ghostty Build Dependencies${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check OS
if [ ! -f /etc/os-release ]; then
    print_error "Cannot detect OS. This script is for Ubuntu/Debian."
    exit 1
fi

source /etc/os-release

if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
    print_error "This script is for Ubuntu/Debian. Your OS: $ID"
    exit 1
fi

print_success "Detected: $PRETTY_NAME"
echo ""

# Step 1: Install GTK4 development libraries
print_step "Step 1/4: Installing GTK4 development libraries..."

GTK_DEPS=(
    "libgtk-4-dev"
    "libadwaita-1-dev"
    "gettext"
    "libxml2-utils"
)

# Check for gtk4-layer-shell availability
if apt-cache show libgtk4-layer-shell-dev &>/dev/null; then
    GTK_DEPS+=("libgtk4-layer-shell-dev")
    echo "   libgtk4-layer-shell-dev is available in repositories"
else
    print_warning "libgtk4-layer-shell-dev not available (will compile from source during build)"
    echo "   This is normal for Ubuntu 24.04 and earlier"
    echo "   The build will use -fno-sys=gtk4-layer-shell flag automatically"
fi

echo ""
echo "Installing GTK4 dependencies:"
for dep in "${GTK_DEPS[@]}"; do
    echo "   - $dep"
done
echo ""

sudo apt update
sudo apt install -y "${GTK_DEPS[@]}"

print_success "GTK4 dependencies installed"
echo ""

# Step 2: Install blueprint-compiler
print_step "Step 2/4: Installing blueprint-compiler..."

REQUIRED_BLUEPRINT_VERSION="0.16.0"

if command -v blueprint-compiler &> /dev/null; then
    CURRENT_VERSION=$(blueprint-compiler --version 2>&1 | grep -oP '\d+\.\d+\.\d+' || echo "0.0.0")
    echo "   Current version: $CURRENT_VERSION"

    # Simple version comparison
    if [[ "$CURRENT_VERSION" == "$REQUIRED_BLUEPRINT_VERSION" ]] || [[ "$CURRENT_VERSION" > "$REQUIRED_BLUEPRINT_VERSION" ]]; then
        print_success "blueprint-compiler $CURRENT_VERSION is already installed"
    else
        print_warning "blueprint-compiler version $CURRENT_VERSION is too old"
        echo "   Required: $REQUIRED_BLUEPRINT_VERSION or newer"
        echo "   Attempting to upgrade..."
        sudo apt install -y blueprint-compiler
    fi
else
    echo "   Installing blueprint-compiler..."
    sudo apt install -y blueprint-compiler

    if command -v blueprint-compiler &> /dev/null; then
        INSTALLED_VERSION=$(blueprint-compiler --version 2>&1 | grep -oP '\d+\.\d+\.\d+' || echo "unknown")
        print_success "blueprint-compiler $INSTALLED_VERSION installed"

        if [[ "$INSTALLED_VERSION" < "$REQUIRED_BLUEPRINT_VERSION" ]]; then
            print_warning "Installed version may be too old (required: $REQUIRED_BLUEPRINT_VERSION+)"
            echo "   The build may fail. Consider upgrading Ubuntu or installing from source."
        fi
    else
        print_error "Failed to install blueprint-compiler"
        exit 1
    fi
fi

echo ""

# Step 3: Install Zig compiler
print_step "Step 3/4: Installing Zig compiler..."

REQUIRED_ZIG_VERSION="0.14.1"

if command -v zig &> /dev/null; then
    CURRENT_ZIG=$(zig version 2>&1)
    echo "   Current version: $CURRENT_ZIG"

    if [[ "$CURRENT_ZIG" == "$REQUIRED_ZIG_VERSION" ]]; then
        print_success "Zig $REQUIRED_ZIG_VERSION is already installed at $(which zig)"
    else
        print_warning "Zig version mismatch"
        echo "   Current: $CURRENT_ZIG"
        echo "   Required: $REQUIRED_ZIG_VERSION"
        read -p "Replace with Zig $REQUIRED_ZIG_VERSION? (Y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            INSTALL_ZIG=true
        fi
    fi
else
    echo "   Zig not found, will install"
    INSTALL_ZIG=true
fi

if [ "$INSTALL_ZIG" = true ]; then
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"

    ARCH=$(uname -m)
    ZIG_TARBALL="zig-linux-${ARCH}-${REQUIRED_ZIG_VERSION}.tar.xz"
    DOWNLOAD_URL="https://ziglang.org/download/${REQUIRED_ZIG_VERSION}/${ZIG_TARBALL}"

    print_step "Downloading Zig ${REQUIRED_ZIG_VERSION}..."
    echo "   URL: $DOWNLOAD_URL"

    if ! curl -LO "$DOWNLOAD_URL"; then
        print_error "Failed to download Zig"
        cd - > /dev/null
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    print_step "Extracting Zig..."
    tar -xf "$ZIG_TARBALL"

    print_step "Installing Zig to /usr/local/zig-${REQUIRED_ZIG_VERSION}..."
    sudo rm -rf "/usr/local/zig-${REQUIRED_ZIG_VERSION}"
    sudo mv "zig-linux-${ARCH}-${REQUIRED_ZIG_VERSION}" "/usr/local/zig-${REQUIRED_ZIG_VERSION}"

    # Create or update symlink
    print_step "Creating symlink at /usr/local/bin/zig..."
    sudo ln -sf "/usr/local/zig-${REQUIRED_ZIG_VERSION}/zig" /usr/local/bin/zig

    # Clean up
    cd - > /dev/null
    rm -rf "$TEMP_DIR"

    # Verify
    if command -v zig &> /dev/null; then
        INSTALLED_ZIG=$(zig version 2>&1)
        print_success "Zig $INSTALLED_ZIG installed successfully"
        echo "   Location: $(which zig)"
    else
        print_error "Zig installation failed"
        exit 1
    fi
fi

echo ""

# Step 4: Install basic build tools
print_step "Step 4/4: Installing basic build tools..."

BUILD_DEPS=(
    "build-essential"
    "git"
    "curl"
    "pkg-config"
)

sudo apt install -y "${BUILD_DEPS[@]}"

print_success "Build tools installed"
echo ""

# Summary
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Dependency Installation Complete${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Installed components:"
echo ""

# GTK4
if dpkg -l | grep -q "libgtk-4-dev"; then
    GTK_VERSION=$(dpkg -l | grep "libgtk-4-dev" | awk '{print $3}')
    echo -e "${GREEN}✓${NC} GTK4 development libraries ($GTK_VERSION)"
else
    echo -e "${RED}✗${NC} GTK4 development libraries"
fi

# libadwaita
if dpkg -l | grep -q "libadwaita-1-dev"; then
    ADWAITA_VERSION=$(dpkg -l | grep "libadwaita-1-dev" | awk '{print $3}')
    echo -e "${GREEN}✓${NC} libadwaita ($ADWAITA_VERSION)"
else
    echo -e "${RED}✗${NC} libadwaita"
fi

# blueprint-compiler
if command -v blueprint-compiler &> /dev/null; then
    BP_VERSION=$(blueprint-compiler --version 2>&1 | grep -oP '\d+\.\d+\.\d+' || echo "unknown")
    echo -e "${GREEN}✓${NC} blueprint-compiler ($BP_VERSION)"
else
    echo -e "${RED}✗${NC} blueprint-compiler"
fi

# Zig
if command -v zig &> /dev/null; then
    ZIG_VER=$(zig version 2>&1)
    ZIG_LOC=$(which zig)
    echo -e "${GREEN}✓${NC} Zig compiler ($ZIG_VER)"
    echo "   Location: $ZIG_LOC"
else
    echo -e "${RED}✗${NC} Zig compiler"
fi

# build-essential
if command -v gcc &> /dev/null && command -v make &> /dev/null; then
    GCC_VER=$(gcc --version | head -1)
    echo -e "${GREEN}✓${NC} Build tools (gcc, make, etc.)"
else
    echo -e "${RED}✗${NC} Build tools"
fi

echo ""
print_success "All dependencies are ready for building Ghostty from source!"
echo ""
echo "Next step: Run ./scripts/install-from-source.sh"
