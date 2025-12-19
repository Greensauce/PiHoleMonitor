# Contributing to Pi-hole Plasma Widget

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to the project.

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on the issue, not the person
- Help others learn and grow

## How Can I Contribute?

### Reporting Bugs

Before creating a bug report:
1. Check the [existing issues](https://github.com/YOUR_USERNAME/pihole-plasma-widget/issues)
2. Check the [troubleshooting guide](TROUBLESHOOTING.md)
3. Verify you're using the latest version

When creating a bug report, include:
- **Widget version** (check in Configure → About)
- **Pi-hole version** (`pihole -v`)
- **KDE Plasma version** (`plasmashell --version`)
- **Operating system** (e.g., "CachyOS, Arch Linux")
- **Steps to reproduce**
- **Expected behavior**
- **Actual behavior**
- **Logs** (from `journalctl --user -u plasma-plasmashell | grep "Pi-hole"`)
- **Screenshots** if applicable

### Suggesting Features

Feature requests are welcome! Please:
- Check if the feature already exists or is planned
- Clearly describe the feature and its benefits
- Explain your use case
- Consider if it fits the widget's scope

### Pull Requests

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

3. **Make your changes**
   - Follow the existing code style
   - Test your changes thoroughly
   - Update documentation if needed

4. **Commit your changes**
   ```bash
   git commit -m "Add amazing feature"
   ```
   - Use clear, descriptive commit messages
   - Reference issues when applicable (#123)

5. **Push to your fork**
   ```bash
   git push origin feature/amazing-feature
   ```

6. **Open a Pull Request**
   - Clearly describe what changes you made and why
   - Link to any related issues
   - Include screenshots if UI changed

## Development Setup

### Prerequisites

- KDE Plasma 6
- Qt 6 / QML
- A running Pi-hole instance (for testing)
- Text editor or IDE

### Getting Started

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/pihole-plasma-widget.git
cd pihole-plasma-widget

# Install the widget locally
./install-widget.sh

# Restart Plasma to load changes
plasmashell --replace &
disown
```

### Project Structure

```
pihole-plasma-widget/
├── org.kde.plasma.pihole/          # Widget source
│   ├── contents/
│   │   ├── code/
│   │   │   └── pihole.js           # API client (Pi-hole v5 & v6)
│   │   ├── config/
│   │   │   └── main.xml            # Configuration schema
│   │   └── ui/
│   │       ├── main.qml            # Main widget UI
│   │       └── config/
│   │           └── configGeneral.qml # Settings UI
│   ├── metadata.json               # Widget metadata (Plasma 6)
│   └── metadata.desktop            # Desktop entry
├── install-widget.sh               # Installation script
├── README.md
├── CHANGELOG.md
└── CONTRIBUTING.md                 # This file
```

### Making Changes

#### UI Changes (QML)

Edit files in `org.kde.plasma.pihole/contents/ui/`:
- `main.qml` - Main widget (compact & expanded views)
- `config/configGeneral.qml` - Settings dialog

After changes:
```bash
# Restart Plasma
plasmashell --replace &
disown
```

#### API Changes (JavaScript)

Edit `org.kde.plasma.pihole/contents/code/pihole.js`:
- Handles both Pi-hole v5 and v6 APIs
- Session management for v6
- Error handling

#### Configuration Changes

Edit `org.kde.plasma.pihole/contents/config/main.xml`:
- Add new configuration options here
- Update `configGeneral.qml` to expose them in UI

### Testing

1. **Test with Pi-hole v5 and v6** if possible
2. **Test all features:**
   - Status monitoring
   - Enable/Disable
   - All disable durations
   - Configuration changes
   - Error handling (wrong password, network down, etc.)
3. **Test at different widget sizes**
4. **Check logs for errors:**
   ```bash
   journalctl --user -u plasma-plasmashell -f | grep "Pi-hole"
   ```

### Code Style

- **QML**: Follow Qt QML coding conventions
- **JavaScript**: 
  - Use camelCase for variables/functions
  - Add comments for complex logic
  - Include error handling
- **Indentation**: 4 spaces (no tabs)
- **Line length**: Aim for <120 characters
- **Comments**: Explain *why*, not *what*

### Commit Messages

Format:
```
Short summary (50 chars or less)

More detailed explanation if needed (wrap at 72 chars).

- Bullet points are fine
- Reference issues: Fixes #123

```

Examples:
```
Fix status parsing for Pi-hole v6 API

The v6 API returns "enabled"/"disabled" as strings, not booleans.
Updated parsing logic to handle both string and boolean values.

Fixes #42
```

## Documentation

When adding features:
- Update README.md
- Add entries to CHANGELOG.md
- Update screenshots if UI changed
- Add troubleshooting steps if applicable

## Release Process

(For maintainers)

1. Update version in:
   - `metadata.json`
   - `metadata.desktop`
   - `CHANGELOG.md`

2. Create git tag:
   ```bash
   git tag -a v2.7.1 -m "Release v2.7.1"
   git push origin v2.7.1
   ```

3. Create GitHub release with:
   - Release notes from CHANGELOG
   - Compiled `.tar.gz` package
   - Installation instructions

## Getting Help

- **Questions**: Open a [GitHub Discussion](https://github.com/YOUR_USERNAME/pihole-plasma-widget/discussions)
- **Bugs**: Open an [Issue](https://github.com/YOUR_USERNAME/pihole-plasma-widget/issues)
- **Chat**: (Add Discord/Matrix if created)

## Recognition

Contributors will be recognized in:
- CHANGELOG.md
- README.md credits section
- GitHub contributors page

Thank you for contributing! 🎉
