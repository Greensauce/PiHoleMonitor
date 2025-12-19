# Quick Start Guide

## Installation

1. Extract the archive
2. Run the installer:
   ```bash
   cd pihole-plasma-widget
   ./install-widget.sh
   ```
3. Restart Plasma:
   ```bash
   plasmashell --replace &
   disown
   ```

## Add Widget

1. Right-click desktop or panel
2. Select "Add Widgets"
3. Search for "Pi-hole"
4. Click to add

## Configuration

1. Right-click widget and select "Configure"

2. Get your credentials:
   
   **For Pi-hole v6:**
   - Open: http://your-pihole-ip/admin
   - Login
   - Go to Settings → API → Application passwords
   - Generate new password
   - Copy the generated password

   **For Pi-hole v5:**
   - Open: http://your-pihole-ip/admin
   - Go to Settings → API
   - Click "Show API token"
   - Copy the token

3. Enter configuration:
   - Pi-hole IP Address: Your Pi-hole's IP (e.g., 192.168.1.100)
   - App Password/API Key: Paste the credential you copied
   - Update Interval: 30 seconds (default)
   - Click Apply

## Usage

**Compact View:**
- Icon shows status (green = active, red = disabled)
- Text shows current state
- Click to expand

**Expanded View:**
- View detailed status
- Enable/disable protection
- Choose disable duration:
  - 10 seconds
  - 30 seconds
  - 5 minutes
  - 10 minutes
  - 30 minutes
  - Indefinitely
- Refresh status manually

## Troubleshooting

**Widget shows "Not Configured":**
- Right-click widget → Configure
- Enter Pi-hole IP and credentials

**Widget shows "Connection Error":**
- Verify Pi-hole IP address is correct
- Verify credentials are valid
- Ensure Pi-hole is running and accessible
- Check network connectivity

**Widget not appearing in list:**
- Re-run installation script
- Restart Plasma (log out and back in)
- Clear Plasma cache: rm -rf ~/.cache/plasma*

## Uninstall

```bash
kpackagetool6 --type=Plasma/Applet --remove org.kde.plasma.pihole
plasmashell --replace &
disown
```
