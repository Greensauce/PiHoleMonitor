# Pi-hole Widget Troubleshooting Guide

## Version 2.0 - Improved Error Handling & Debugging

This version includes much better error messages and console logging to help diagnose connection issues.

## Quick Diagnostics

### Step 1: View Debug Logs

After installing the widget and configuring it, check the console logs for detailed error information:

```bash
# Watch live logs as the widget tries to connect
journalctl --user -u plasma-plasmashell -f | grep "Pi-hole Widget"
```

Or check recent logs:
```bash
journalctl --user -u plasma-plasmashell --since "5 minutes ago" | grep "Pi-hole"
```

The logs will show exactly what URL the widget is trying to reach and what error it's getting.

### Step 2: Test Pi-hole Connection Manually

Test if you can reach your Pi-hole from your CachyOS desktop:

**Test basic connectivity:**
```bash
# Replace with your Pi-hole IP
ping -c 3 192.168.1.100

# Or use hostname
ping -c 3 YummiPi.local
```

**Test Pi-hole web interface:**
```bash
# Should return HTML
curl http://192.168.1.100/admin/
```

**Test v5 API (older Pi-hole):**
```bash
# Replace YOUR_API_KEY with your App Password or API token
curl "http://192.168.1.100/admin/api.php?status&auth=YOUR_API_KEY"
```

Should return JSON like: `{"status":"enabled"}`

**Test v6 API (Pi-hole 6.0+):**
```bash
# Test auth endpoint
curl -X POST http://192.168.1.100/api/auth \
  -H "Content-Type: application/json" \
  -d '{"password":"YOUR_APP_PASSWORD"}'
```

## Common Issues & Solutions

### Issue: "Network error - cannot reach Pi-hole"

**Cause:** Widget cannot connect to the IP address

**Solutions:**
1. **Verify IP address is correct**
   ```bash
   # If using hostname
   ping YummiPi.local
   
   # Check what IP it resolves to
   getent hosts YummiPi.local
   ```

2. **Try using IP instead of hostname**
   - In widget config, use `192.168.1.X` instead of `YummiPi.local`
   - Find IP: `ssh pi@YummiPi.local "hostname -I"`

3. **Check firewall on CachyOS**
   ```bash
   # Check if firewall is blocking
   sudo systemctl status firewalld
   
   # If running, allow HTTP
   sudo firewall-cmd --add-service=http --permanent
   sudo firewall-cmd --reload
   ```

4. **Check Pi-hole is running**
   ```bash
   ssh pi@YummiPi.local "pihole status"
   ```

### Issue: "Authentication failed - check your App Password/API Key"

**Cause:** The App Password or API Key is incorrect

**Solutions for Pi-hole v6.0+:**

1. **Generate a new App Password:**
   - Open: `http://your-pi-hole/admin`
   - Login to Pi-hole
   - Go to: **Settings**
   - Scroll to: **API** section
   - Under "Application passwords":
     - Enter name: `Plasma Widget`
     - Click **Generate** or **Add**
   - **IMPORTANT:** Copy the ENTIRE password immediately
   - Paste into widget configuration

2. **Common mistakes:**
   - Not copying the full password (it's long!)
   - Extra spaces at beginning/end
   - Using the wrong password type

**Solutions for Pi-hole v5.x:**

1. **Get the API token:**
   - Open: `http://your-pi-hole/admin`
   - Go to: **Settings → API**
   - Click: **Show API token**
   - Copy the entire token
   - Paste into widget configuration

### Issue: "Cannot connect to Pi-hole. Check IP address and App Password"

**This means BOTH v5 and v6 APIs failed. Check logs for details:**

```bash
journalctl --user -u plasma-plasmashell --since "2 minutes ago" | grep "Pi-hole"
```

Look for lines like:
- `v5 status HTTP status: 0` = Network problem
- `v5 status HTTP status: 401` = Wrong password
- `v5 status HTTP status: 404` = Wrong URL/endpoint
- `v5 timeout` = Pi-hole not responding

### Issue: Widget shows "Error" but no details

1. **Check you filled in both fields:**
   - Pi-hole IP Address (required)
   - App Password/API Key (required)

2. **Restart the widget:**
   - Remove widget from desktop
   - Add it again
   - Reconfigure

3. **Check console for JavaScript errors:**
   ```bash
   journalctl --user -u plasma-plasmashell -f
   ```

### Issue: "Timeout connecting to Pi-hole"

**Cause:** Pi-hole not responding within 5 seconds

**Solutions:**
1. **Check Pi-hole is running:**
   ```bash
   ssh pi@YummiPi.local "systemctl status pihole-FTL"
   ```

2. **Check network latency:**
   ```bash
   ping -c 10 YummiPi.local
   ```
   If latency > 1000ms, you have network issues

3. **Restart Pi-hole:**
   ```bash
   ssh pi@YummiPi.local "pihole restartdns"
   ```

## Manual Testing Workflow

To fully debug the connection, do this in order:

### 1. Test Network Connectivity
```bash
ping -c 3 YummiPi.local
# Should show < 10ms response times on local network
```

### 2. Test HTTP Access
```bash
curl -I http://YummiPi.local/admin/
# Should return "HTTP/1.1 200 OK"
```

### 3. Test Pi-hole v5 API
```bash
# Without auth (should work but return limited info)
curl "http://YummiPi.local/admin/api.php?status"

# With auth (replace YOUR_KEY)
curl "http://YummiPi.local/admin/api.php?status&auth=YOUR_APP_PASSWORD"
```

If this returns `{"status":"enabled"}` or `{"status":"disabled"}`, your API key works!

### 4. Test Pi-hole v6 API (if you have v6)
```bash
# Get session
curl -X POST http://YummiPi.local/api/auth \
  -H "Content-Type: application/json" \
  -d '{"password":"YOUR_APP_PASSWORD"}'

# Should return: {"session":{"sid":"...", "validity":300}}
```

### 5. Check Widget Configuration

Make sure in the widget settings:
- **Pi-hole IP Address:** `YummiPi.local` or `192.168.1.X` (NO http://, NO /admin)
- **App Password:** Exact password from Pi-hole (no spaces)
- **Update Interval:** 5 seconds (default)

### 6. Check Widget Logs

```bash
# Open another terminal and watch logs
journalctl --user -u plasma-plasmashell -f | grep "Pi-hole"

# In widget, click "Refresh Status"
# Watch what happens in the logs
```

## Getting More Help

If you're still stuck, gather this information:

1. **Pi-hole version:**
   ```bash
   ssh pi@YummiPi.local "pihole -v"
   ```

2. **What you see in widget:**
   - Icon color?
   - Text shown?
   - What happens when you click it?

3. **Console logs:**
   ```bash
   journalctl --user -u plasma-plasmashell --since "5 minutes ago" | grep -i "pihole\|error"
   ```

4. **Manual curl test result:**
   ```bash
   curl "http://YummiPi.local/admin/api.php?status&auth=YOUR_KEY"
   ```

5. **Network test:**
   ```bash
   ping -c 5 YummiPi.local
   ```

## Advanced Debugging

### Enable More Verbose Logging

The widget logs are already enabled in v2.0. To see ALL Plasma/QML logs:

```bash
# Set environment variable
export QT_LOGGING_RULES="*.debug=true"

# Restart Plasma
plasmashell --replace &
disown

# Now all QML/Qt logs will appear
journalctl --user -u plasma-plasmashell -f
```

### Test with Simple Python Script

Create a test script to verify your App Password works:

```python
#!/usr/bin/env python3
import requests
import json

# EDIT THESE
PIHOLE_IP = "192.168.1.100"  # Your Pi-hole IP
APP_PASSWORD = "your_app_password_here"

# Test v5 API
print("Testing v5 API...")
try:
    r = requests.get(f"http://{PIHOLE_IP}/admin/api.php?status&auth={APP_PASSWORD}", timeout=5)
    print(f"Status Code: {r.status_code}")
    print(f"Response: {r.text}")
except Exception as e:
    print(f"Error: {e}")

# Test v6 API
print("\nTesting v6 API...")
try:
    r = requests.post(f"http://{PIHOLE_IP}/api/auth", 
                      json={"password": APP_PASSWORD},
                      headers={"Content-Type": "application/json"},
                      timeout=5)
    print(f"Status Code: {r.status_code}")
    print(f"Response: {r.text}")
except Exception as e:
    print(f"Error: {e}")
```

Run with: `python3 test_pihole.py`

## Known Limitations

1. **CORS Issues:** Some Pi-hole configurations might block API requests from Plasma (rare)
2. **HTTPS Not Supported:** Widget only supports HTTP (most Pi-holes use HTTP locally)
3. **DNS Conflicts:** If your CachyOS is using Pi-hole for DNS and you're debugging, you might have circular issues

## What Changed in v2.0

- ✅ Added comprehensive console logging
- ✅ Better error messages with specific details
- ✅ Validates inputs before making requests
- ✅ Tries v5 API first (more compatible), falls back to v6
- ✅ 5-second timeout on all requests
- ✅ Shows network vs. auth vs. parsing errors separately
- ✅ Logs full API URLs (with password redacted)

All API calls are logged to the console so you can see exactly what's happening.

---

**Still having issues?** Share your debug logs and manual curl test results!
