# Troubleshooting Guide

Common issues and solutions for Ghostty setup and usage.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Launch Issues](#launch-issues)
- [Configuration Issues](#configuration-issues)
- [Display Issues](#display-issues)
- [Performance Issues](#performance-issues)
- [Matrix Effects Issues](#matrix-effects-issues)
- [Font Issues](#font-issues)
- [Build Issues](#build-issues)

---

## Installation Issues

### "ghostty: command not found"

**Problem**: Ghostty binary is not in your PATH.

**Solutions**:

1. **Check if binary exists**:
   ```bash
   ls ~/.local/bin/ghostty
   ```

2. **Add to PATH** (if file exists):
   ```bash
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

3. **Verify PATH**:
   ```bash
   echo $PATH | grep ".local/bin"
   ```

### Binary Won't Execute

**Problem**: Permission denied or "cannot execute binary file"

**Solutions**:

1. **Check permissions**:
   ```bash
   ls -l ~/.local/bin/ghostty
   ```

2. **Make executable**:
   ```bash
   chmod +x ~/.local/bin/ghostty
   ```

3. **Check architecture**:
   ```bash
   file ~/.local/bin/ghostty
   uname -m
   ```
   If binary is x86_64 but system is ARM, use source install.

### "Package 'libgtk-4-1' not found"

**Problem**: Runtime dependencies missing.

**Solution**:
```bash
sudo apt update
sudo apt install libgtk-4-1 libadwaita-1-0
```

---

## Launch Issues

### Ghostty Crashes on Startup

**Symptoms**: Window opens briefly then closes, or no window appears.

**Diagnostics**:

1. **Run from terminal** to see error messages:
   ```bash
   ghostty --verbose
   ```

2. **Check GTK version**:
   ```bash
   dpkg -l | grep libgtk-4-1
   ```

**Common Causes**:

- **Missing GTK4**: Install runtime libraries (see above)
- **Config syntax error**: Temporarily rename config:
  ```bash
  mv ~/.config/ghostty/config ~/.config/ghostty/config.bak
  ghostty  # Test with default config
  ```

### "Failed to load theme"

**Problem**: Theme file not found or corrupted.

**Solution**:

1. **Check theme exists**:
   ```bash
   ls ~/.config/ghostty/themes/matrix-dramatic
   ```

2. **Recreate theme** from repo:
   ```bash
   cd ~/ghostty-setup
   cp config/themes/matrix-dramatic ~/.config/ghostty/themes/
   ```

3. **Verify config syntax**:
   ```bash
   grep "^theme = " ~/.config/ghostty/config
   ```
   Should be: `theme = matrix-dramatic` (no file extension)

### "Cannot open display"

**Problem**: X11/Wayland display server issue.

**Solutions**:

1. **Check DISPLAY variable** (X11):
   ```bash
   echo $DISPLAY
   # Should show: :0 or :1
   ```

2. **Check Wayland** (if using Wayland):
   ```bash
   echo $WAYLAND_DISPLAY
   # Should show: wayland-0
   ```

3. **Restart display manager**:
   ```bash
   sudo systemctl restart gdm3  # Ubuntu/GNOME
   ```

---

## Configuration Issues

### Changes Don't Apply

**Problem**: Edited config but Ghostty still looks the same.

**Solutions**:

1. **Restart Ghostty completely**:
   - Close all windows
   - Launch fresh instance

2. **Check config location**:
   ```bash
   ls -la ~/.config/ghostty/config
   ```

3. **Verify syntax**:
   ```bash
   cat ~/.config/ghostty/config
   # Look for typos, missing values
   ```

### Theme Switch Doesn't Work

**Problem**: `switch-theme.sh` doesn't change theme.

**Solutions**:

1. **Run script with argument**:
   ```bash
   ~/.config/ghostty/switch-theme.sh matrix-dramatic
   ```

2. **Check script permissions**:
   ```bash
   chmod +x ~/.config/ghostty/switch-theme.sh
   ```

3. **Manually edit config**:
   ```bash
   nano ~/.config/ghostty/config
   # Find: theme = ...
   # Change to: theme = matrix-dramatic
   ```

4. **Restart Ghostty** after changing.

### Keybindings Don't Work

**Problem**: Ctrl+Shift+T (etc.) doesn't work.

**Causes**:

1. **Desktop environment intercepts keys**: GNOME/KDE may use same shortcuts
2. **Config syntax error**: Check `keybind =` lines in config

**Solutions**:

1. **Test keybinding**:
   ```bash
   # Open Ghostty, try: Ctrl+Shift+T
   # If nothing happens, check system shortcuts
   ```

2. **Check for conflicts**:
   - GNOME: Settings → Keyboard → View and Customize Shortcuts
   - KDE: Settings → Shortcuts

3. **Use different keybindings**:
   ```ini
   keybind = ctrl+alt+t=new_tab
   ```

---

## Display Issues

### Font Doesn't Look Right

**Problem**: Font appears pixelated, wrong size, or different family.

**Solutions**:

1. **Verify JetBrains Mono is installed**:
   ```bash
   fc-list | grep -i jetbrains
   ```

2. **Install font**:
   ```bash
   cd ~/ghostty-setup
   ./scripts/install-fonts.sh
   ```

3. **Check font config**:
   ```bash
   grep "^font-family" ~/.config/ghostty/config
   grep "^font-size" ~/.config/ghostty/config
   ```

4. **Rebuild font cache**:
   ```bash
   fc-cache -f -v
   ```

5. **Restart Ghostty**.

### Colors Look Washed Out

**Problem**: Colors don't match screenshots, look dull.

**Causes**:

1. **Wrong theme loaded**
2. **Terminal color support**
3. **Compositor effects**

**Solutions**:

1. **Check current theme**:
   ```bash
   grep "^theme" ~/.config/ghostty/config
   ```

2. **Verify TERM variable**:
   ```bash
   echo $TERM
   # Should be: xterm-256color or ghostty
   ```

3. **Test colors**:
   ```bash
   # Run this in Ghostty
   for i in {0..255}; do printf "\x1b[38;5;${i}mcolour${i}\x1b[0m  "; done
   ```

4. **Disable compositor** (temporarily):
   - GNOME: Extensions → Disable animations
   - KDE: System Settings → Desktop Effects → Suspend

### Transparency Not Working

**Problem**: `background-opacity` setting doesn't make background transparent.

**Solutions**:

1. **Check compositor is running**:
   ```bash
   ps aux | grep -i compos
   ```

2. **Check config value**:
   ```bash
   grep "background-opacity" ~/.config/ghostty/config
   # Should be between 0.0 and 1.0
   ```

3. **Try different values**:
   ```ini
   background-opacity = 0.8  # More transparent
   background-opacity = 0.95 # Slightly transparent
   ```

4. **Restart Ghostty**.

---

## Performance Issues

### Ghostty Feels Sluggish

**Problem**: Slow text rendering, input lag, or animations stutter.

**Diagnostics**:

1. **Check system resources**:
   ```bash
   top
   # Look for high CPU/RAM usage
   ```

2. **Check GPU acceleration**:
   ```bash
   ghostty --version
   # Should show: renderer: OpenGL
   ```

**Solutions**:

1. **Close other applications** (free up RAM)

2. **Disable transparency**:
   ```ini
   background-opacity = 1.0
   ```

3. **Reduce font size** (fewer pixels to render):
   ```ini
   font-size = 10  # Instead of 11 or 12
   ```

4. **Check for GPU driver issues**:
   ```bash
   glxinfo | grep "OpenGL renderer"
   ```

### High CPU Usage

**Problem**: Ghostty uses lots of CPU even when idle.

**Causes**:

1. **Matrix effects running**
2. **Busy shell prompt** (oh-my-zsh with many plugins)
3. **Background processes in terminal**

**Solutions**:

1. **Kill Matrix effects**:
   ```bash
   pkill unimatrix
   pkill cxxmatrix
   ```

2. **Simplify shell prompt**:
   ```bash
   # Test with basic prompt
   PS1='$ '
   ```

3. **Check for background jobs**:
   ```bash
   jobs
   ```

---

## Matrix Effects Issues

### unimatrix Not Found

**Problem**: `unimatrix: command not found`

**Solutions**:

1. **Install unimatrix**:
   ```bash
   cd ~/ghostty-setup
   ./scripts/install-matrix-tools.sh
   # Choose option 1
   ```

2. **Check installation**:
   ```bash
   which unimatrix
   # Should show: ~/.local/bin/unimatrix
   ```

3. **Verify PATH**:
   ```bash
   echo $PATH | grep ".local/bin"
   ```

### cxxmatrix Build Fails

**Problem**: Error during `make` when building cxxmatrix.

**Solutions**:

1. **Install build tools**:
   ```bash
   sudo apt install build-essential g++ make git
   ```

2. **Retry build**:
   ```bash
   cd ~/ghostty-setup
   ./scripts/install-matrix-tools.sh
   # Choose option 2
   ```

### Matrix Effects Lag/Stutter

**Problem**: Matrix rain runs slowly or choppy.

**Solutions**:

1. **Reduce speed** (unimatrix):
   ```bash
   unimatrix -s 50  # Lower = slower but smoother
   ```

2. **Use simpler version** (cmatrix):
   ```bash
   cmatrix -u 2  # Update delay in 1/10 seconds
   ```

3. **Close other terminals/apps**.

---

## Font Issues

### "JetBrains Mono not found"

**Problem**: Font doesn't appear in `fc-list` output.

**Solutions**:

1. **Install from repositories**:
   ```bash
   sudo apt update
   sudo apt install fonts-jetbrains-mono
   ```

2. **Install from GitHub** (if package not available):
   ```bash
   cd ~/ghostty-setup
   ./scripts/install-fonts.sh
   # Choose option 2
   ```

3. **Rebuild font cache**:
   ```bash
   fc-cache -f -v ~/.local/share/fonts
   ```

4. **Verify installation**:
   ```bash
   fc-list | grep -i jetbrains | head -5
   ```

### Font Renders Poorly at Small Sizes

**Problem**: Text looks blurry or pixelated at font-size < 10.

**Solutions**:

1. **Use recommended size**:
   ```ini
   font-size = 11  # Or 12
   ```

2. **Enable font hinting** (if Ghostty supports it):
   ```ini
   # Check Ghostty docs for font rendering options
   ```

3. **Try different font**:
   ```ini
   font-family = Fira Code
   font-family = Source Code Pro
   ```

---

## Build Issues

### Zig Version Mismatch

**Problem**: `error: zig version mismatch` during build.

**Solution**:

1. **Check Zig version**:
   ```bash
   zig version
   # Must be exactly: 0.14.1
   ```

2. **Install correct Zig**:
   ```bash
   cd ~/ghostty-setup
   ./scripts/install-dependencies.sh
   ```

3. **Verify installation**:
   ```bash
   which zig
   zig version
   ```

### blueprint-compiler Not Found

**Problem**: Build fails with "blueprint-compiler: command not found"

**Solutions**:

1. **Install blueprint-compiler**:
   ```bash
   sudo apt install blueprint-compiler
   ```

2. **Verify version** (need 0.16.0+):
   ```bash
   blueprint-compiler --version
   ```

3. **If version too old**, upgrade Ubuntu or build from source.

### GTK4 Development Headers Missing

**Problem**: Build fails with "gtk4 not found" or similar.

**Solution**:
```bash
sudo apt update
sudo apt install \
    libgtk-4-dev \
    libadwaita-1-dev \
    gettext \
    libxml2-utils
```

### Build Runs Out of Memory

**Problem**: System freezes or build crashes with "out of memory"

**Solutions**:

1. **Close other applications**.

2. **Add swap space**:
   ```bash
   sudo fallocate -l 4G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   ```

3. **Build on system with more RAM** (4GB minimum, 8GB recommended).

### Build Takes Too Long

**Problem**: Build has been running for over an hour.

**Normal**: First build can take 20-30 minutes on slower systems.

**If stuck**:

1. **Check if actually building**:
   ```bash
   ps aux | grep zig
   # Should show zig processes
   ```

2. **Check disk activity**:
   ```bash
   iostat -x 2
   ```

3. **If truly stuck**, kill and restart:
   ```bash
   pkill zig
   # Then retry: zig build -Doptimize=ReleaseFast
   ```

---

## Getting More Help

### Check Logs

**Ghostty logs** (if available):
```bash
journalctl --user | grep ghostty
```

**System logs**:
```bash
dmesg | tail -50
```

### Verbose Mode

Run Ghostty with debug output:
```bash
ghostty --verbose
```

### Reset to Defaults

If all else fails, reset configuration:

```bash
# Backup current config
mv ~/.config/ghostty ~/.config/ghostty.backup

# Reinstall clean config
cd ~/ghostty-setup
./scripts/install-binary.sh
```

### Report an Issue

If you found a bug:

1. **For Ghostty bugs**: https://github.com/ghostty-org/ghostty/issues
2. **For setup scripts**: Open issue in this repository

Include:
- Operating system and version
- Ghostty version (`ghostty --version`)
- Full error message
- Steps to reproduce

---

## Quick Reference: Common Commands

```bash
# Check Ghostty version
ghostty --version

# Check if Ghostty is running
ps aux | grep ghostty

# Rebuild font cache
fc-cache -f -v

# Reset config
mv ~/.config/ghostty/config ~/.config/ghostty/config.bak

# Reinstall from repo
cd ~/ghostty-setup && ./scripts/install-binary.sh

# Switch theme
~/.config/ghostty/switch-theme.sh matrix-dramatic

# Test with default config
ghostty --config /dev/null
```

---

Happy troubleshooting! 🔧
