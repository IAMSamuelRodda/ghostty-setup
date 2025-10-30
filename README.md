# Ghostty Terminal Setup

A complete Ghostty terminal configuration with Matrix-themed aesthetics, ready to deploy on Ubuntu/Debian Linux systems.

## Features

- **Matrix-themed configuration** - High-contrast green terminal with dramatic colors
- **Pre-built binary** for Ubuntu 24.04/25.04 (x86_64) - Install in 5 minutes
- **Source build option** for other distros or architectures
- **Multiple themes** - Switch between Matrix and dark themes
- **Matrix rain effects** - Optional installation of unimatrix, cxxmatrix, or cmatrix
- **JetBrains Mono font** - Optimized for coding
- **Automated installation scripts** - Step-by-step guided setup

## Quick Start

### Option 1: Binary Install (Recommended - 5 minutes)

For Ubuntu 24.04/25.04 on x86_64:

```bash
git clone https://github.com/IAMSamuelRodda/ghostty-setup.git
cd ghostty-setup
./scripts/install-binary.sh
```

**What it does:**
- ✓ Installs pre-built Ghostty binary to `~/.local/bin/`
- ✓ Deploys configuration to `~/.config/ghostty/`
- ✓ Offers to install JetBrains Mono font
- ✓ Offers to install Matrix rain effects

### Option 2: Build from Source (20-30 minutes)

For other Linux distros or if you want the latest version:

```bash
git clone https://github.com/IAMSamuelRodda/ghostty-setup.git
cd ghostty-setup
./scripts/install-from-source.sh
```

**What it does:**
- ✓ Checks and installs all build dependencies
- ✓ Downloads Ghostty source (you choose version)
- ✓ Builds from source with Zig 0.14.1
- ✓ Installs binary to `~/.local/bin/` or `/usr/local/bin/`
- ✓ Deploys configuration and offers optional components

## What's Included

### Ghostty Configuration

- **Font**: JetBrains Mono 11pt
- **Opacity**: 90% for modern aesthetics
- **Window decoration**: Client-side (thin titlebar)
- **Cursor**: Blinking block
- **Auto-copy on selection**: Enabled
- **Tab management**: Ctrl+Shift+T/W/Left/Right

### Themes

1. **matrix-dramatic** (default)
   - Rich black background (#030303)
   - Vibrant green foreground (#1CA152)
   - High contrast for readability
   - Matrix aesthetic throughout

2. **default-dark**
   - Standard dark theme
   - Good for general use

Switch themes with:
```bash
~/.config/ghostty/switch-theme.sh matrix-dramatic
~/.config/ghostty/switch-theme.sh default-dark
```

### Optional Matrix Effects

Install Matrix rain screensavers:

- **unimatrix** - Python-based, easy to install
- **cxxmatrix** - C++ powerhouse with multiple scenes (rain, Game of Life, Mandelbrot)
- **cmatrix** - Classic C implementation

```bash
./scripts/install-matrix-tools.sh
```

## Installation Guides

### Step-by-Step: Binary Installation

**Prerequisites:**
- Ubuntu 24.04 or 25.04
- x86_64 architecture
- Internet connection

**Steps:**

1. **Clone this repository**
   ```bash
   git clone https://github.com/IAMSamuelRodda/ghostty-setup.git
   cd ghostty-setup
   ```

2. **Run the installer**
   ```bash
   ./scripts/install-binary.sh
   ```

3. **Follow prompts**
   - Choose whether to overwrite existing config (if any)
   - Choose whether to install fonts
   - Choose whether to install Matrix effects

4. **Verify installation**
   ```bash
   ghostty --version
   ```

5. **Launch Ghostty**
   ```bash
   ghostty
   ```

### Step-by-Step: Source Installation

**Prerequisites:**
- Ubuntu/Debian Linux (any version)
- 4GB+ RAM for building
- 10GB free disk space
- Internet connection

**Steps:**

1. **Clone this repository**
   ```bash
   git clone https://github.com/IAMSamuelRodda/ghostty-setup.git
   cd ghostty-setup
   ```

2. **Run the source installer**
   ```bash
   ./scripts/install-from-source.sh
   ```

3. **Follow prompts**
   - Install dependencies (if needed)
   - Choose Ghostty version (stable/specific/development)
   - Choose install location (user/system)
   - Wait for build (~15-20 minutes)
   - Choose whether to install optional components

4. **Reload shell**
   ```bash
   source ~/.bashrc
   ```

5. **Launch Ghostty**
   ```bash
   ghostty
   ```

## Repository Structure

```
ghostty-setup/
├── bin/
│   └── ghostty-x86_64-linux      # Pre-built binary (30MB)
├── config/
│   ├── config                     # Main Ghostty configuration
│   └── themes/
│       ├── matrix-dramatic        # Matrix green theme
│       └── default-dark           # Standard dark theme
├── scripts/
│   ├── install-binary.sh          # Quick binary install
│   ├── install-from-source.sh     # Build from source
│   ├── install-dependencies.sh    # Install build tools
│   ├── install-fonts.sh           # Install JetBrains Mono
│   ├── install-matrix-tools.sh    # Install Matrix effects
│   └── switch-theme.sh            # Theme switcher utility
├── docs/
│   ├── QUICKSTART.md              # Fast start guide
│   ├── BUILD_FROM_SOURCE.md       # Detailed build guide
│   └── TROUBLESHOOTING.md         # Common issues
└── README.md                      # This file
```

## Dependencies

### Runtime Dependencies (Binary Install)
- libgtk-4-1
- libadwaita-1-0
- Standard system libraries

### Build Dependencies (Source Install)
- Zig 0.14.1 (exact version required)
- libgtk-4-dev
- libadwaita-1-dev
- blueprint-compiler 0.16.0+
- gettext
- libxml2-utils
- build-essential

All dependencies are automatically installed by `install-from-source.sh`.

## Customization

### Changing Font

Edit `~/.config/ghostty/config`:
```ini
font-family = Your Font Name
font-size = 12
```

### Creating Custom Themes

1. Copy an existing theme:
   ```bash
   cp ~/.config/ghostty/themes/matrix-dramatic ~/.config/ghostty/themes/my-theme
   ```

2. Edit colors in the new theme file

3. Switch to your theme:
   ```bash
   ~/.config/ghostty/switch-theme.sh my-theme
   ```

### Key Bindings

Current bindings in `config/config`:
- `Ctrl+Shift+T` - New tab
- `Ctrl+Shift+W` - Close tab/window
- `Ctrl+Shift+Right` - Next tab
- `Ctrl+Shift+Left` - Previous tab

## Documentation

- [Quick Start Guide](docs/QUICKSTART.md) - Get running in 5 minutes
- [Build from Source](docs/BUILD_FROM_SOURCE.md) - Detailed build instructions
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions

## System Requirements

### Binary Installation
- Ubuntu 24.04 or 25.04
- x86_64 architecture
- ~100MB disk space
- GTK4 runtime libraries

### Source Installation
- Any modern Linux distro
- x86_64 or ARM64
- 4GB+ RAM
- 10GB disk space during build
- Internet connection

## Compatibility

**Tested on:**
- ✅ Ubuntu 25.04 (x86_64)
- ✅ Ubuntu 24.04 (x86_64)

**Should work on:**
- Debian 12+ (testing/unstable)
- Linux Mint 22+
- Pop!_OS 24.04+

**Source build tested on:**
- Ubuntu 25.04
- Debian testing

## FAQ

**Q: Why is the binary so large (30MB)?**
A: Ghostty is a statically linked Zig binary with embedded resources. This makes it portable but larger.

**Q: Can I use this on Ubuntu 22.04?**
A: The binary won't work (GTK4 version mismatch), but source installation should work.

**Q: Does this work on ARM (Raspberry Pi)?**
A: Use the source installation method - the binary is x86_64 only.

**Q: How do I update Ghostty?**
A: Re-run the installation script, or manually build a newer version from source.

**Q: Can I contribute themes?**
A: Yes! Submit a PR with your theme file in `config/themes/`.

## Troubleshooting

### Binary won't run
```bash
# Check dependencies
ldd ~/.local/bin/ghostty

# Install missing GTK4 libraries
sudo apt install libgtk-4-1 libadwaita-1-0
```

### Build fails
```bash
# Verify Zig version (must be exactly 0.14.1)
zig version

# Reinstall dependencies
./scripts/install-dependencies.sh
```

### Theme doesn't apply
```bash
# Check theme file exists
ls ~/.config/ghostty/themes/

# Manually set theme in config
nano ~/.config/ghostty/config
# Change: theme = matrix-dramatic
```

See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for more solutions.

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Test on Ubuntu 24.04/25.04
4. Submit a pull request

## License

MIT License - See LICENSE file for details.

Ghostty itself is maintained by Mitchell Hashimoto and the Ghostty project contributors.

## Credits

- **Ghostty Terminal**: [ghostty.org](https://ghostty.org) by Mitchell Hashimoto
- **Matrix Theme**: Custom color palette inspired by The Matrix
- **JetBrains Mono**: [JetBrains](https://www.jetbrains.com/lp/mono/)
- **Matrix Effects**:
  - unimatrix: [github.com/will8211/unimatrix](https://github.com/will8211/unimatrix)
  - cxxmatrix: [github.com/akinomyoga/cxxmatrix](https://github.com/akinomyoga/cxxmatrix)
  - cmatrix: Classic terminal Matrix effect

## Support

- **Ghostty Issues**: [github.com/ghostty-org/ghostty/issues](https://github.com/ghostty-org/ghostty/issues)
- **Setup Issues**: Open an issue in this repository
- **Documentation**: [ghostty.org/docs](https://ghostty.org/docs)

---

**Enjoy your Matrix-themed terminal experience!** 🟢
