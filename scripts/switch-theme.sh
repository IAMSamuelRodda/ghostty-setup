#!/bin/bash
# Ghostty Theme Switcher
# Usage: ./switch-theme.sh <theme-name>
# Available themes: matrix-dramatic, default-dark

CONFIG_FILE="$HOME/.config/ghostty/config"
THEME_NAME="${1:-matrix-dramatic}"

if [ -z "$1" ]; then
    echo "Available themes:"
    ls -1 "$HOME/.config/ghostty/themes/" 2>/dev/null || echo "  No themes found"
    echo ""
    echo "Current theme:"
    grep "^theme = " "$CONFIG_FILE" 2>/dev/null || echo "  No theme set"
    echo ""
    echo "Usage: $0 <theme-name>"
    exit 0
fi

# Check if theme exists
if [ ! -f "$HOME/.config/ghostty/themes/$THEME_NAME" ]; then
    echo "Error: Theme '$THEME_NAME' not found"
    echo "Available themes:"
    ls -1 "$HOME/.config/ghostty/themes/"
    exit 1
fi

# Update config file
if grep -q "^theme = " "$CONFIG_FILE"; then
    # Replace existing theme line
    sed -i "s|^theme = .*|theme = $THEME_NAME|" "$CONFIG_FILE"
else
    # Add theme line after the comment block
    sed -i "/^# - themes\\/default-dark/a theme = $THEME_NAME" "$CONFIG_FILE"
fi

echo "Theme switched to: $THEME_NAME"
echo "Restart ghostty or open a new window to see changes"
