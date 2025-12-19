# Changelog

All notable changes to the Pi-hole Plasma Widget will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.7.1] - 2024-12-13

### Fixed
- Fixed syntax error (extra closing brace) that prevented widget from loading in v2.7

## [2.7.0] - 2024-12-13

### Added
- Title now shows in compact/panel view (not just expanded view)
- Widget layout now matches KDE system widgets (Memory Usage, CPU Usage, etc.)

### Changed
- Compact view changed from horizontal (Row) to vertical (Column) layout
- Title appears above status in panel view

## [2.6.0] - 2024-12-13

### Fixed
- **CRITICAL**: Fixed v6 API status parsing - widget was incorrectly treating string "disabled" as truthy
- Status now updates correctly after disabling Pi-hole
- Timer countdown now stays synchronized with Pi-hole server

### Added
- Smart API version detection - widget "learns" which API version (v5/v6) works
- Timer extraction from v6 API responses
- Reduced API calls by 50% (no more wasteful v5 attempts after learning v6)

### Changed
- Widget now prefers learned API version instead of always trying v5 first
- Improved logging - cleaner output without repeated 400 errors

## [2.5.0] - 2024-12-13

### Added
- Configurable widget title
- "Show Widget Title" toggle in settings
- Customizable title text (default: "Pi-hole Status")

### Changed
- Status update timing - trusts disable API response instead of immediately querying again
- Improved title word wrapping for long titles

## [2.4.0] - 2024-12-13

### Added
- "Paused" prefix to countdown timer for clarity
- Shorter button labels to fit better ("10 sec" instead of "10 seconds")

### Fixed
- Buttons no longer extend beyond widget boundaries
- All controls now visible within widget bounds at any size

### Changed
- Increased minimum widget size (16x18 grid units)
- Moved spacer to bottom of layout
- Hide main buttons when showing disable options
- Updated author to "Bryan Greenaway & Claude"

## [2.3.1] - 2024-12-13

### Fixed
- Fixed configuration change monitoring (removed invalid `onConfigurationChanged` property)
- Used proper `Connections` object for monitoring config changes

## [2.3.0] - 2024-12-13

### Added
- Inline disable duration options (replaced broken popup dialog)
- Visual debug panel showing real-time widget actions
- Timestamps for all actions
- Configuration change detection

### Changed
- Disable options now appear inline in expanded view instead of popup dialog
- Circular status icons (emblem-checked/emblem-warning)

### Fixed
- Dialog not opening when clicking "Disable Pi-hole"
- Icons appearing tilted (replaced with upright circular icons)

## [2.2.0] - 2024-12-13

### Added
- Visual debug panel in expanded view
- Real-time action feedback
- Success/failure messages with timestamps

### Fixed
- Attempted to fix tilted icons (partial fix - completed in v2.3)

## [2.1.0] - 2024-12-13

### Added
- Enhanced logging for toggle and disable functions
- More detailed debug output

### Fixed
- Icons (attempted - used shield icons that didn't exist properly)

## [2.0.0] - 2024-12-13

### Added
- Comprehensive error handling and debugging
- Console logging for all API operations
- Better error messages with specific details
- Support for both Pi-hole v5 and v6 APIs

### Changed
- Updated configuration help text for Pi-hole v6 App Passwords
- Tries v5 API first, falls back to v6

## [1.3.0] - 2024-12-13

### Added
- Configuration page now visible in widget settings
- Multiple config file locations for better Plasma 6 compatibility

### Fixed
- "General" tab missing from configuration dialog
- Configuration settings now accessible

## [1.2.0] - 2024-12-13

### Fixed
- Configuration panel integration with Plasma 6
- Removed KCM.SimpleKCM wrapper for native integration

## [1.1.0] - 2024-12-13

### Added
- Full Plasma 6 compatibility metadata
- PlasmaComponents3 imports

### Fixed
- "Not compatible with Plasma 6" warning

## [1.0.0] - 2024-12-13

### Added
- Initial release
- Basic Pi-hole monitoring and control
- Compact and expanded views
- Enable/Disable functionality
- Configurable refresh interval
- Support for Pi-hole v5 API

### Features
- Status monitoring (enabled/disabled)
- Quick disable with preset durations
- Automatic status refresh
- Color-coded visual indicators
- Secure API key storage

## [Unreleased]

### Planned
- Statistics view (queries blocked, percentage)
- Multiple Pi-hole instance support
- Whitelist/blacklist management
- Query log viewer
- Custom themes/colors
- Network status indicators
- Notification support

---

## Release Notes

### v2.7.1 - Stability Release
Quick fix for syntax error introduced in v2.7.

### v2.7.0 - UI Enhancement
Major UI update bringing widget appearance in line with KDE system widgets.

### v2.6.0 - Critical Bug Fix
Essential update fixing status parsing bug and improving performance. All users should upgrade.

### v2.5.0 - Customization
Added title customization options.

### v2.4.0 - Polish
UI refinements and layout improvements.

### v2.3.0 - Working Disable
First version with fully functional inline disable options.

### v2.0.0 - Foundation
Major rewrite with Pi-hole v6 support and comprehensive error handling.

### v1.0.0 - First Release
Initial working version with basic functionality.

---

**Note:** Versions prior to 2.0.0 were development versions with various issues.
The recommended minimum version is **2.6.0** or later.
