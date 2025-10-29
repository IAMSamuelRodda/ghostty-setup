# Building Ghostty from Source

Complete guide to building Ghostty from source on Ubuntu/Debian Linux.

## Why Build from Source?

Build from source if you:
- ✓ Use a non-Ubuntu distro (Debian, Mint, Pop!_OS, etc.)
- ✓ Need ARM architecture support (Raspberry Pi, etc.)
- ✓ Want the latest development version
- ✓ Use Ubuntu 22.04 or older (GTK4 incompatibility)
- ✓ Want to customize the build

## Prerequisites

### System Requirements

- **OS**: Any modern Linux distro (Ubuntu, Debian, Fedora, Arch, etc.)
- **Architecture**: x86_64 or ARM64
- **RAM**: 4GB minimum, 8GB recommended
- **Disk Space**: ~10GB during build (can clean up after)
- **Internet**: Required for downloading dependencies and source

### Time Requirements

- **First-time build**: 20-30 minutes
- **Dependency installation**: 5-10 minutes
- **Subsequent builds**: 5-10 minutes (cached)

## Automated Installation

The easiest way is to use our script:

```bash
git clone https://github.com/yourusername/ghostty-setup.git
cd ghostty-setup
./scripts/install-from-source.sh
```

The script will:
1. Check your system
2. Install all dependencies
3. Download Ghostty source
4. Build Ghostty
5. Install binary and config
6. Offer optional components

**Continue reading for manual build instructions.**

## Manual Build Instructions

### Step 1: Install Build Dependencies

#### Ubuntu/Debian:

```bash
# GTK4 development libraries
sudo apt update
sudo apt install -y \
    libgtk-4-dev \
    libadwaita-1-dev \
    gettext \
    libxml2-utils \
    build-essential \
    git \
    curl \
    pkg-config

# Optional: gtk4-layer-shell (if available)
sudo apt install -y libgtk4-layer-shell-dev
```

**Note**: Ubuntu 24.04 and earlier don't have `libgtk4-layer-shell-dev`. This is fine - Ghostty will compile it from source.

#### Install blueprint-compiler:

```bash
sudo apt install -y blueprint-compiler

# Verify version (need 0.16.0+)
blueprint-compiler --version
```

### Step 2: Install Zig 0.14.1

Ghostty requires **exactly Zig 0.14.1**. Don't use a different version.

#### Download and install:

```bash
cd ~
ARCH=$(uname -m)
ZIG_VERSION="0.14.1"

# Download
curl -LO "https://ziglang.org/download/${ZIG_VERSION}/zig-linux-${ARCH}-${ZIG_VERSION}.tar.xz"

# Extract
tar -xf "zig-linux-${ARCH}-${ZIG_VERSION}.tar.xz"

# Install system-wide
sudo mv "zig-linux-${ARCH}-${ZIG_VERSION}" /usr/local/zig-${ZIG_VERSION}
sudo ln -sf /usr/local/zig-${ZIG_VERSION}/zig /usr/local/bin/zig

# Verify
zig version
# Should output: 0.14.1
```

### Step 3: Download Ghostty Source

Choose one of three options:

#### Option A: Latest Stable Release (Recommended)

```bash
mkdir -p ~/ghostty-build
cd ~/ghostty-build

VERSION="1.2.0"
curl -LO "https://release.files.ghostty.org/${VERSION}/ghostty-${VERSION}.tar.gz"
tar -xzf "ghostty-${VERSION}.tar.gz"
cd "ghostty-${VERSION}"
```

#### Option B: Specific Version

Check available versions at: https://ghostty.org/download

```bash
mkdir -p ~/ghostty-build
cd ~/ghostty-build

VERSION="1.1.0"  # Change to desired version
curl -LO "https://release.files.ghostty.org/${VERSION}/ghostty-${VERSION}.tar.gz"
tar -xzf "ghostty-${VERSION}.tar.gz"
cd "ghostty-${VERSION}"
```

#### Option C: Development Tip (Bleeding Edge)

```bash
mkdir -p ~/ghostty-build
cd ~/ghostty-build

git clone https://github.com/ghostty-org/ghostty.git
cd ghostty
```

**Warning**: Development builds may have bugs and require different Zig versions.

### Step 4: Configure Build

#### Check if gtk4-layer-shell is available:

```bash
apt-cache show libgtk4-layer-shell-dev
```

If not available, you'll need the `-Dno-sys=gtk4-layer-shell` flag.

### Step 5: Build Ghostty

```bash
# If gtk4-layer-shell is available:
zig build -Doptimize=ReleaseFast

# If NOT available (Ubuntu 24.04 and earlier):
zig build -Doptimize=ReleaseFast -Dno-sys=gtk4-layer-shell
```

**This will take 10-20 minutes.** You'll see lots of output. This is normal.

#### Build Output:

The built binary will be at: `zig-out/bin/ghostty`

### Step 6: Test the Binary

```bash
./zig-out/bin/ghostty --version
```

Should output something like:
```
Ghostty 1.2.0-dev+0000000
```

### Step 7: Install Ghostty

#### Option A: User Installation (Recommended)

Installs to `~/.local/bin/ghostty` (no sudo required):

```bash
zig build -p ~/.local -Doptimize=ReleaseFast
```

Or with gtk4-layer-shell flag if needed:
```bash
zig build -p ~/.local -Doptimize=ReleaseFast -Dno-sys=gtk4-layer-shell
```

#### Option B: System-wide Installation

Installs to `/usr/local/bin/ghostty` (requires sudo):

```bash
sudo zig build -p /usr/local -Doptimize=ReleaseFast
```

### Step 8: Verify Installation

```bash
which ghostty
ghostty --version
```

### Step 9: Install Configuration

```bash
# Clone this repo (if you haven't already)
cd ~
git clone https://github.com/yourusername/ghostty-setup.git

# Copy config files
mkdir -p ~/.config/ghostty
cp ~/ghostty-setup/config/config ~/.config/ghostty/
cp -r ~/ghostty-setup/config/themes ~/.config/ghostty/
cp ~/ghostty-setup/scripts/switch-theme.sh ~/.config/ghostty/
chmod +x ~/.config/ghostty/switch-theme.sh
```

### Step 10: Add to PATH (if needed)

If you installed to `~/.local/bin/` and it's not in your PATH:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Step 11: Launch Ghostty

```bash
ghostty
```

## Optional Components

### Install JetBrains Mono Font

```bash
cd ~/ghostty-setup
./scripts/install-fonts.sh
```

### Install Matrix Effects

```bash
cd ~/ghostty-setup
./scripts/install-matrix-tools.sh
```

## Clean Up Build Files

After successful installation, you can remove the build directory:

```bash
rm -rf ~/ghostty-build
```

This frees up ~10GB of disk space.

## Updating Ghostty

To update to a newer version:

```bash
cd ~/ghostty-build/ghostty-VERSION
git pull  # If using git
# Or download new tarball

zig build -Doptimize=ReleaseFast -p ~/.local
```

## Build Options

### Debug Build

For development or troubleshooting:

```bash
zig build  # No -Doptimize flag
```

Debug builds are larger and slower but provide better error messages.

### Custom Build Flags

```bash
# Build with tests
zig build test

# Build and run
zig build run

# Build distribution tarball
zig build dist
```

See `zig build --help` for all options.

## Troubleshooting Build Issues

### Zig Version Mismatch

**Error**: `error: zig version mismatch`

**Solution**: Install exactly Zig 0.14.1:
```bash
zig version  # Check current version
# Follow Step 2 above to install correct version
```

### Missing blueprint-compiler

**Error**: `blueprint-compiler not found`

**Solution**:
```bash
sudo apt install blueprint-compiler
blueprint-compiler --version  # Verify 0.16.0+
```

### GTK4 Not Found

**Error**: `gtk4 not found` or `libadwaita not found`

**Solution**:
```bash
sudo apt update
sudo apt install libgtk-4-dev libadwaita-1-dev
```

### Out of Memory

**Error**: Build crashes or system freezes

**Solution**: Close other applications, or add swap:
```bash
# Create 4GB swap file (if you don't have one)
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### Build Takes Forever

This is normal. First build can take 20-30 minutes on slower systems.

**Speed up future builds**:
- Keep the build directory (don't delete `~/ghostty-build`)
- Zig caches compiled dependencies
- Subsequent builds only take 5-10 minutes

## Build on Other Distros

### Fedora

```bash
sudo dnf install gtk4-devel libadwaita-devel gettext libxml2 gcc git curl

# Install blueprint-compiler and Zig manually (same as Ubuntu steps)
```

### Arch Linux

```bash
sudo pacman -S gtk4 libadwaita blueprint-compiler gettext libxml2 base-devel git curl

# Install Zig manually (same as Ubuntu steps)
```

### Debian

Same as Ubuntu instructions.

## Platform-Specific Notes

### ARM64 (Raspberry Pi, etc.)

Same steps, but:
- Build will be slower (30-60 minutes)
- Download ARM64 Zig build:
  ```bash
  ARCH=aarch64  # Instead of x86_64
  ```

### Wayland vs X11

Ghostty supports both automatically. No special configuration needed.

## Advanced Build Configuration

### Custom Installation Prefix

```bash
zig build -p /opt/ghostty -Doptimize=ReleaseFast
```

### Statically Linked Build

Zig builds are already mostly static, but you can experiment:

```bash
zig build -Doptimize=ReleaseFast -Dtarget=native-linux-musl
```

## Getting Help

- **Ghostty build docs**: https://ghostty.org/docs/install/build
- **Zig download**: https://ziglang.org/download/
- **Ghostty GitHub**: https://github.com/ghostty-org/ghostty
- **This repo issues**: Open an issue for setup-specific problems

---

Happy building! 🔨
