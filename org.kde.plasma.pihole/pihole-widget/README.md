# Pi-hole Plasma Widget - Source Code

This directory contains the complete source code for the Pi-hole Plasma Widget.

## Directory Structure

```
org.kde.plasma.pihole/
├── contents/
│   ├── code/
│   │   └── pihole.js          # Pi-hole API client library
│   ├── config/
│   │   └── main.xml           # Configuration schema
│   └── ui/
│       ├── main.qml           # Main widget component
│       └── config/
│           └── configGeneral.qml  # Configuration panel UI
├── metadata.json              # Widget metadata (Plasma 6)
├── metadata.desktop           # Widget metadata (legacy format)
└── README.md                  # This file
```

## File Descriptions

### `contents/code/pihole.js`
**Purpose:** Pi-hole API client library

**Functionality:**
- Communicates with both Pi-hole v5 and v6 APIs
- Automatic API version detection and preference learning
- Session management for v6 authentication
- Status checking, enable/disable operations
- Comprehensive error handling

**Key Functions:**
- `getStatus(host, apiKey, callback)` - Get current Pi-hole status
- `enable(host, apiKey, callback)` - Enable Pi-hole blocking
- `disable(host, apiKey, seconds, callback)` - Disable for duration
- `formatTime(seconds)` - Format time for display

### `contents/ui/main.qml`
**Purpose:** Main widget UI component

**Functionality:**
- Compact representation (panel view)
- Full representation (expanded view)
- Status monitoring and auto-refresh
- User interaction handling
- Optional debug information display

**Key Components:**
- Properties for status tracking
- Timer-based auto-refresh
- Configuration change monitoring
- Compact view (title + icon + status)
- Full view (detailed status + control buttons)

### `contents/ui/config/configGeneral.qml`
**Purpose:** Configuration panel UI

**Functionality:**
- Pi-hole connection settings (IP, password)
- Widget appearance settings (title, debug)
- Update interval configuration
- Contextual help text

**User Configurable:**
- Pi-hole IP address
- App Password/API Key
- Update interval (3-300 seconds)
- Widget title text
- Show/hide title
- Show/hide debug info

### `contents/config/main.xml`
**Purpose:** Configuration schema

**Defines:**
- Configuration property types
- Default values
- Validation constraints (min/max)
- Property descriptions

### `metadata.json`
**Purpose:** Widget metadata (Plasma 6 format)

**Contains:**
- Plugin information (name, version, authors)
- KDE Plasma API version requirements
- Widget category and description
- Main script location

### `metadata.desktop`
**Purpose:** Widget metadata (legacy format)

**Contains:**
- Same information as metadata.json
- Desktop entry format for compatibility
- Service type declarations

## Code Style Guidelines

### QML Files
- 4-space indentation
- Comprehensive JSDoc-style comments
- Logical section organization with comment headers
- Descriptive variable and function names

### JavaScript Files
- JSDoc comments for all public functions
- `@param` and `@returns` documentation
- Section headers with visual separators
- Private functions marked with `@private`

### Configuration Files
- XML comments for clarity
- Descriptive labels for all entries
- Min/max constraints where applicable

## Development Workflow

### Making Changes

1. **Edit the source files** in this directory
2. **Copy to Plasma directory:**
   ```bash
   cp -r org.kde.plasma.pihole ~/.local/share/plasma/plasmoids/
   ```
3. **Restart Plasma:**
   ```bash
   plasmashell --replace &
   disown
   ```

### Testing

1. **Add widget to panel** or desktop
2. **Configure** with valid Pi-hole credentials
3. **Test all features:**
   - Status monitoring
   - Enable/disable operations
   - All disable durations
   - Configuration changes
   - Error handling (wrong password, network down, etc.)

### Debugging

1. **Enable debug info** in widget settings
2. **Watch logs:**
   ```bash
   journalctl --user -u plasma-plasmashell -f | grep "Pi-hole"
   ```
3. **Check console** in expanded view debug panel

## API Documentation

### Pi-hole v5 API

**Endpoints:**
- Status: `GET /admin/api.php?status&auth=TOKEN`
- Disable: `GET /admin/api.php?disable=SECONDS&auth=TOKEN`
- Enable: `GET /admin/api.php?enable&auth=TOKEN`

**Authentication:** API token passed in URL

### Pi-hole v6 API

**Endpoints:**
- Auth: `POST /api/auth` (body: `{password: "..."}`)
- Status: `GET /api/dns/blocking` (header: `sid: SESSION_ID`)
- Disable: `POST /api/dns/blocking` (header: `sid`, body: `{blocking: false, timer: SECONDS}`)
- Enable: `POST /api/dns/blocking` (header: `sid`, body: `{blocking: true}`)

**Authentication:** Session-based with App Password

## Version History

See [CHANGELOG.md](../../CHANGELOG.md) for complete version history.

## Contributing

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for contribution guidelines.

## License

MIT License - See [LICENSE](../../LICENSE) file for details.

## Authors

Bryan Greenaway & Claude

---

**For user documentation, see the main [README.md](../../README.md) in the repository root.**
