#!/bin/bash
# Ghostty Setup - Matrix Rain Tools Installation
# Installs various Matrix rain effect programs for terminal eye candy

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
echo -e "${BLUE}  Matrix Rain Tools Installation${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Choose your Matrix effects:"
echo ""
echo "  1. unimatrix     - Python-based, easy install, good visuals"
echo "  2. cxxmatrix     - C++ powerhouse, most features (rain, Game of Life, fractals)"
echo "  3. cmatrix       - Classic C implementation, lightweight"
echo "  4. All of above  - Install everything!"
echo "  5. Skip          - No Matrix effects"
echo ""
read -p "Enter choice [1-5]: " -n 1 -r
echo ""
echo ""

install_unimatrix() {
    print_step "Installing unimatrix..."

    # Check if uv is installed
    if ! command -v uv &> /dev/null; then
        print_warning "uv package manager not found"
        echo "Installing uv (fast Python package manager)..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.local/bin:$PATH"
    fi

    # Install unimatrix via uv
    uv tool install unimatrix

    if command -v unimatrix &> /dev/null; then
        print_success "unimatrix installed successfully"
        echo "   Test it: unimatrix -s 96 -l m"
    else
        print_error "unimatrix installation failed"
        return 1
    fi
}

install_cxxmatrix() {
    print_step "Installing cxxmatrix (building from source)..."

    # Check for build dependencies
    MISSING_DEPS=()

    if ! command -v g++ &> /dev/null; then
        MISSING_DEPS+=("g++")
    fi

    if ! command -v make &> /dev/null; then
        MISSING_DEPS+=("make")
    fi

    if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
        print_warning "Installing build dependencies: ${MISSING_DEPS[*]}"
        sudo apt update
        sudo apt install -y build-essential
    fi

    # Clone and build
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"

    print_step "Cloning cxxmatrix repository..."
    git clone https://github.com/akinomyoga/cxxmatrix.git
    cd cxxmatrix

    print_step "Building cxxmatrix..."
    make

    print_step "Installing to /usr/local/bin..."
    sudo make install

    # Clean up
    cd - > /dev/null
    rm -rf "$TEMP_DIR"

    if command -v cxxmatrix &> /dev/null; then
        print_success "cxxmatrix installed successfully"
        echo "   Test it: cxxmatrix"
        echo "   Game of Life: cxxmatrix --scene=conway"
        echo "   Fractals: cxxmatrix --scene=mandelbrot"
    else
        print_error "cxxmatrix installation failed"
        return 1
    fi
}

install_cmatrix() {
    print_step "Installing cmatrix from repositories..."

    if command -v cmatrix &> /dev/null; then
        print_warning "cmatrix is already installed"
        cmatrix -V
        return 0
    fi

    sudo apt update
    sudo apt install -y cmatrix

    if command -v cmatrix &> /dev/null; then
        print_success "cmatrix installed successfully"
        echo "   Test it: cmatrix -ab"
    else
        print_error "cmatrix installation failed"
        return 1
    fi
}

case $REPLY in
    1)
        install_unimatrix
        ;;
    2)
        install_cxxmatrix
        ;;
    3)
        install_cmatrix
        ;;
    4)
        echo -e "${BLUE}Installing all Matrix tools...${NC}"
        echo ""

        install_unimatrix || print_warning "unimatrix installation had issues"
        echo ""

        install_cxxmatrix || print_warning "cxxmatrix installation had issues"
        echo ""

        install_cmatrix || print_warning "cmatrix installation had issues"
        ;;
    5)
        echo "Matrix tools installation skipped."
        exit 0
        ;;
    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Matrix Tools Summary${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Show what's installed
if command -v unimatrix &> /dev/null; then
    echo -e "${GREEN}✓${NC} unimatrix: $(which unimatrix)"
    echo "   Usage: unimatrix -s 96 -l m -c green"
else
    echo -e "${YELLOW}✗${NC} unimatrix: not installed"
fi

if command -v cxxmatrix &> /dev/null; then
    echo -e "${GREEN}✓${NC} cxxmatrix: $(which cxxmatrix)"
    echo "   Usage: cxxmatrix"
    echo "   Scenes: --scene=rain|conway|mandelbrot"
else
    echo -e "${YELLOW}✗${NC} cxxmatrix: not installed"
fi

if command -v cmatrix &> /dev/null; then
    echo -e "${GREEN}✓${NC} cmatrix: $(which cmatrix)"
    echo "   Usage: cmatrix -ab"
else
    echo -e "${YELLOW}✗${NC} cmatrix: not installed"
fi

echo ""
echo "Press Ctrl+C to exit any Matrix effect."
echo ""
print_success "Matrix tools installation complete!"
