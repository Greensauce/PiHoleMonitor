# Quick Start Guide

Get up and running with the Pi-hole Plasma Widget in under 5 minutes!

## Prerequisites Check

Before you begin, make sure you have:

- [ ] KDE Plasma 6 installed
- [ ] A working Pi-hole server on your network
- [ ] Pi-hole IP address or hostname
- [ ] Network connectivity to Pi-hole

## Installation (3 steps)

### Step 1: Download

```bash
wget https://github.com/YOUR_USERNAME/pihole-plasma-widget/releases/latest/download/pihole-plasma-widget.tar.gz
tar -xzf pihole-plasma-widget.tar.gz
cd pihole-plasma-widget
```

### Step 2: Install

```bash
./install-widget.sh
```

### Step 3: Restart Plasma

```bash
plasmashell --replace &
disown
```

## Configuration (2 steps)

### Step 1: Get Your Pi-hole Credentials

#### For Pi-hole v6.0+:
1. Go to http://your-pihole/admin
2. Login
3. Settings → API → Application passwords
4. Enter name: "Plasma Widget"
5. Click Generate
6. Copy the App Password

#### For Pi-hole v5.x:
1. Go to http://your-pihole/admin
2. Settings → API
3. Click "Show API token"
4. Copy the token

### Step 2: Configure Widget

1. Right-click the widget in your panel
2. Click **"Configure"**
3. Enter:
   - **Pi-hole IP**: Your Pi-hole IP (e.g., `192.168.1.100`)
   - **App Password**: Paste from Step 1
4. Click **"Apply"**

## First Use

You should now see:
- Green circle with ✓ and "On" in your panel
- Title "Pi-hole Status" above it

Try disabling:
1. Click the widget
2. Click "Disable Pi-hole"
3. Choose a duration (e.g., "30 sec")
4. Watch it change to red with countdown!

## Troubleshooting

### "Error" message?
- Check Pi-hole IP is correct
- Verify App Password/API key
- Test connectivity: `ping your-pihole-ip`

### Widget not showing?
```bash
# Check if installed
ls ~/.local/share/plasma/plasmoids/ | grep pihole

# Reinstall if needed
cd pihole-plasma-widget
./install-widget.sh
plasmashell --replace &
```

### Still not working?
See full [TROUBLESHOOTING.md](../TROUBLESHOOTING.md) guide.

## Next Steps

- Customize the title: Configure → Widget Title
- Change update interval: Configure → Update Interval
- Read the [full README](../README.md) for all features

## Quick Tips

- **Disable quickly**: Just click widget → Disable Pi-hole → pick time
- **Re-enable early**: Click widget → Enable Pi-hole
- **Check status**: Green ✓ = enabled, Red ✗ = disabled
- **See countdown**: Shows "Paused 23s" when disabled temporarily

Enjoy your new widget! 🎉
