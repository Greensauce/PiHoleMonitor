# Pi-hole Plasma Widget

KDE Plasma 6 widget for monitoring and controlling Pi-hole DNS blocker.

## Features

- Real-time status monitoring
- Quick enable/disable controls
- Temporary disable with preset durations (10s, 30s, 5m, 10m, 30m)
- Automatic status updates
- Support for Pi-hole v5 and v6
- Compact panel view and expanded full view
- Countdown timer display
- Auto-refresh when timer expires

## Requirements

- KDE Plasma 6
- Pi-hole v5 or v6
- Pi-hole App Password (v6) or API Token (v5)

## Installation

### Quick Install

```bash
cd ~/Downloads
tar -xzf pihole-plasma-widget.tar.gz
cd pihole-plasma-widget
./install-widget.sh
```

Restart Plasma:
```bash
plasmashell --replace &
disown
```

### Manual Install

```bash
kpackagetool6 --type=Plasma/Applet --install org.kde.plasma.pihole
```

## Configuration

1. Right-click the widget
2. Select "Configure"
3. Enter Pi-hole IP address
4. Enter App Password or API Token
5. Adjust update interval (default: 30 seconds)
6. Click Apply

### Getting Credentials

**Pi-hole v6:**
1. Login to Pi-hole admin interface
2. Go to Settings → API → Application passwords
3. Generate new password
4. Copy and paste into widget

**Pi-hole v5:**
1. Login to Pi-hole admin interface
2. Go to Settings → API
3. Click "Show API token"
4. Copy and paste into widget

## Usage

**Panel View:**
- Shows icon and status (Active/Disabled/Paused)
- Click to expand

**Expanded View:**
- View current status
- Enable/disable protection
- Choose disable duration
- Refresh status manually

## Uninstallation

```bash
kpackagetool6 --type=Plasma/Applet --remove org.kde.plasma.pihole
```

## Troubleshooting

**Widget shows "Not configured":**
- Configure Pi-hole IP and App Password

**Widget shows "Connection Error":**
- Verify Pi-hole IP address is correct
- Verify App Password/API Token is valid
- Check network connectivity
- Ensure Pi-hole web interface is accessible

**Widget shows wrong status:**
- Click "Refresh Status"
- Check update interval setting

## Development

### File Structure

```
org.kde.plasma.pihole/
├── contents/
│   ├── code/
│   │   └── pihole.js          # API client library
│   ├── config/
│   │   └── main.xml           # Configuration schema
│   └── ui/
│       ├── main.qml           # Main widget UI
│       └── config/
│           └── configGeneral.qml  # Configuration UI
├── metadata.json              # Widget metadata
└── metadata.desktop          # Desktop entry
```

### Building

```bash
tar -czf pihole-plasma-widget.tar.gz pihole-widget/ install-widget.sh README.md
```

## License

MIT License - See LICENSE file for details

## Authors

Bryan Greenaway & Claude

## Version

2.9.0
