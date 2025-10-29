# Quick Start Guide

Get Ghostty running on your Ubuntu system in 5 minutes with the pre-built binary.

## Prerequisites

- ✓ Ubuntu 24.04 or 25.04
- ✓ x86_64 architecture (64-bit Intel/AMD)
- ✓ Internet connection
- ✓ ~100MB free disk space

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/ghostty-setup.git
cd ghostty-setup
```

### 2. Run the Binary Installer

```bash
./scripts/install-binary.sh
```

### 3. Answer the Prompts

The installer will ask you:

**a. If Ghostty is already installed:**
```
Overwrite existing installation? (y/N)
```
- Choose `y` to replace it
- Choose `n` to keep your current installation

**b. If config already exists:**
```
Backup and replace existing config? (y/N)
```
- Choose `y` to backup and use Matrix theme
- Choose `n` to keep your current config

**c. Install JetBrains Mono font:**
```
Install JetBrains Mono font? (Y/n)
```
- Choose `Y` (default) - recommended for best appearance
- Choose `n` to skip (Ghostty will use fallback fonts)

**d. Install Matrix rain effects:**
```
Install Matrix rain effects? (Y/n)
```
- Choose `Y` (default) for eye candy
- Choose `n` to skip

### 4. Reload Your Shell

```bash
source ~/.bashrc
```

Or simply close and reopen your terminal.

### 5. Launch Ghostty

```bash
ghostty
```

That's it! You should now have Ghostty running with the Matrix theme.

## First Steps After Installation

### Try the Matrix Theme

The default theme is `matrix-dramatic`. Your terminal should have:
- Rich black background
- Vibrant green text
- High contrast colors

### Switch Themes

```bash
# List available themes
~/.config/ghostty/switch-theme.sh

# Switch to dark theme
~/.config/ghostty/switch-theme.sh default-dark

# Switch back to Matrix
~/.config/ghostty/switch-theme.sh matrix-dramatic
```

Restart Ghostty or open a new window to see the change.

### Test Matrix Effects (if installed)

```bash
# Unimatrix
unimatrix -s 96 -l m

# CXXMatrix (if you installed it)
cxxmatrix

# CMatrix (if you installed it)
cmatrix -ab
```

Press `Ctrl+C` to exit any Matrix effect.

### Keyboard Shortcuts

- **Ctrl+Shift+T** - Open new tab
- **Ctrl+Shift+W** - Close tab/window
- **Ctrl+Shift+→** - Next tab
- **Ctrl+Shift+←** - Previous tab
- **Shift+Insert** - Paste
- **Middle-click** - Paste (mouse selection is auto-copied)

## Verifying Installation

### Check Binary Location

```bash
which ghostty
# Should output: /home/yourusername/.local/bin/ghostty
```

### Check Version

```bash
ghostty --version
# Should output: Ghostty 1.2.0-dev+0000000
```

### Check Config

```bash
cat ~/.config/ghostty/config | grep theme
# Should output: theme = matrix-dramatic
```

### Check Font

```bash
fc-list | grep -i jetbrains
# Should show JetBrains Mono fonts
```

## Customization Quick Tips

### Change Font Size

Edit `~/.config/ghostty/config`:

```bash
nano ~/.config/ghostty/config
```

Find and change:
```ini
font-size = 11  # Change to 12, 13, etc.
```

Save and restart Ghostty.

### Change Background Opacity

```bash
nano ~/.config/ghostty/config
```

Find and change:
```ini
background-opacity = 0.9  # Range: 0.0 (transparent) to 1.0 (opaque)
```

Save and restart Ghostty.

### Change Cursor Style

```bash
nano ~/.config/ghostty/config
```

Options:
```ini
cursor-style = block       # Solid block (default)
cursor-style = bar         # Vertical bar
cursor-style = underline   # Underline

cursor-style-blink = true  # Enable blinking
cursor-style-blink = false # Disable blinking
```

## Troubleshooting Quick Fixes

### Ghostty command not found

```bash
# Add to PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Font looks wrong

```bash
# Verify JetBrains Mono is installed
fc-list | grep -i jetbrains

# If not, install it
./scripts/install-fonts.sh
```

### Theme not applying

```bash
# Verify theme file exists
ls ~/.config/ghostty/themes/matrix-dramatic

# Manually check config
cat ~/.config/ghostty/config | grep theme

# Force theme switch
~/.config/ghostty/switch-theme.sh matrix-dramatic
```

### GTK errors on launch

```bash
# Install GTK4 runtime
sudo apt update
sudo apt install libgtk-4-1 libadwaita-1-0
```

## Next Steps

Once you're comfortable with Ghostty, explore:

1. **Create custom themes** - Copy and modify existing themes
2. **Customize keybindings** - Edit config to add your own shortcuts
3. **Try Matrix effects** - Install all three and compare
4. **Explore Ghostty docs** - Visit [ghostty.org/docs](https://ghostty.org/docs)

## Need More Help?

- **Detailed build guide**: [BUILD_FROM_SOURCE.md](BUILD_FROM_SOURCE.md)
- **Common issues**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Main README**: [README.md](../README.md)

---

Enjoy your new terminal! 🟢
