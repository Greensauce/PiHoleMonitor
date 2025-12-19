#!/bin/bash

# Pi-hole Plasma Widget Installer
# Version 2.9.0
# License: MIT

set -e

WIDGET_NAME="org.kde.plasma.pihole"
WIDGET_DIR="pihole-widget"
INSTALL_DIR="$HOME/.local/share/plasma/plasmoids"

echo "================================================"
echo "Pi-hole Plasma Widget Installer"
echo "Version 2.9.0"
echo "================================================"
echo ""

if [ ! -d "$WIDGET_DIR" ]; then
    echo "Error: $WIDGET_DIR directory not found"
    echo "Please run this script from the extracted archive directory"
    exit 1
fi

echo "Creating installation directory..."
mkdir -p "$INSTALL_DIR"

if [ -d "$INSTALL_DIR/$WIDGET_NAME" ]; then
    echo "Removing old version..."
    rm -rf "$INSTALL_DIR/$WIDGET_NAME"
fi

echo "Installing widget..."
cp -r "$WIDGET_DIR" "$INSTALL_DIR/$WIDGET_NAME"

echo "Clearing Plasma cache..."
rm -rf ~/.cache/plasma* 2>/dev/null || true

echo ""
echo "================================================"
echo "Installation Complete"
echo "================================================"
echo ""
echo "Next steps:"
echo ""
echo "1. Restart Plasma:"
echo "   plasmashell --replace & disown"
echo ""
echo "2. Add widget:"
echo "   Right-click desktop → Add Widgets → Search 'Pi-hole'"
echo ""
echo "3. Configure:"
echo "   Right-click widget → Configure → Enter IP and credentials"
echo ""
