# GitHub Repository Setup Instructions

This guide will help you publish the Pi-hole Plasma Widget to GitHub.

## Prerequisites

- GitHub account
- Git installed on your system
- The repository files in this directory

## Step 1: Create GitHub Repository

1. Go to https://github.com/new
2. Repository settings:
   - **Name**: `pihole-plasma-widget`
   - **Description**: "KDE Plasma 6 widget for monitoring and controlling Pi-hole"
   - **Public** (recommended) or Private
   - **DO NOT** initialize with README, .gitignore, or license (we have those)
3. Click **"Create repository"**

## Step 2: Initialize Local Repository

```bash
cd /path/to/github-repo

# Initialize git repository
git init

# Add all files
git add .

# Create first commit
git commit -m "Initial commit - Pi-hole Plasma Widget v2.7.1"
```

## Step 3: Connect to GitHub

Replace `YOUR_USERNAME` with your actual GitHub username:

```bash
# Add remote
git remote add origin https://github.com/YOUR_USERNAME/pihole-plasma-widget.git

# Set main branch
git branch -M main

# Push to GitHub
git push -u origin main
```

## Step 4: Configure Repository Settings

### Topics/Tags
Add these topics to help people find your repository:
1. Go to your repository on GitHub
2. Click the gear icon next to "About"
3. Add topics:
   - `kde-plasma`
   - `plasma-widget`
   - `pihole`
   - `plasma6`
   - `kde`
   - `dns`
   - `ad-blocker`
   - `qml`

### Repository Description
Set description: "KDE Plasma 6 desktop widget for monitoring and controlling your Pi-hole DNS blocker"

### Website (optional)
If you have a project website, add it here.

## Step 5: Update README Links

The README.md contains placeholder links. Update these:

1. Replace all instances of `YOUR_USERNAME` with your GitHub username:
   ```bash
   # In the github-repo directory
   find . -type f -name "*.md" -exec sed -i 's/YOUR_USERNAME/your-actual-username/g' {} +
   ```

2. Or manually edit:
   - README.md
   - CONTRIBUTING.md
   - docs/QUICKSTART.md

## Step 6: Add Screenshots

1. Take screenshots of the widget (see docs/screenshots/README.md)
2. Add them to `docs/screenshots/`
3. Commit:
   ```bash
   git add docs/screenshots/*.png
   git commit -m "Add screenshots"
   git push
   ```

## Step 7: Create First Release

### Option A: Using GitHub Web Interface

1. Go to your repository on GitHub
2. Click **"Releases"** → **"Create a new release"**
3. Click **"Choose a tag"** → type `v2.7.1` → **"Create new tag"**
4. Release title: `v2.7.1 - Stable Release`
5. Description: Copy from CHANGELOG.md
6. Upload `pihole-plasma-widget.tar.gz`
7. Click **"Publish release"**

### Option B: Using Git Tags (triggers automated release)

```bash
# Create annotated tag
git tag -a v2.7.1 -m "Release v2.7.1 - Stable Release"

# Push tag to GitHub
git push origin v2.7.1
```

This will trigger the GitHub Actions workflow to automatically create the release.

## Step 8: Enable GitHub Features

### Discussions (Optional)
1. Go to Settings → General
2. Scroll to Features
3. Enable **Discussions**
4. Good for Q&A and community

### Issues
Should be enabled by default. Configure labels:
- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Documentation improvements
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention needed

### Wiki (Optional)
Enable if you want to add extended documentation.

## Step 9: Set Up Protection Rules (Optional)

For `main` branch:
1. Go to Settings → Branches
2. Add rule for `main`
3. Enable:
   - Require pull request reviews
   - Require status checks to pass

## Step 10: Create First Tarball Release

```bash
# In your github-repo directory
tar -czf pihole-plasma-widget.tar.gz \
    org.kde.plasma.pihole/ \
    install-widget.sh \
    README.md \
    LICENSE \
    docs/QUICKSTART.md

# Upload this to your first GitHub release
```

## Verification Checklist

After setup, verify:

- [ ] Repository is public (or private if intended)
- [ ] README displays correctly
- [ ] Topics/tags are set
- [ ] Issue templates work
- [ ] License is visible
- [ ] First release is created
- [ ] Install instructions work from release
- [ ] All links in README work

## Promoting Your Repository

After publishing:

1. **Reddit**: Share in /r/kde, /r/pihole, /r/selfhosted
2. **KDE Forums**: Post in Plasma section
3. **Pi-hole Discourse**: Share in community
4. **Social Media**: Tweet with #KDE #Plasma #PiHole

## Maintenance

Regular tasks:
- Respond to issues within 48 hours
- Review pull requests
- Update CHANGELOG.md for each release
- Tag releases with semantic versioning
- Keep README current

## Getting Help

If you get stuck:
- GitHub Docs: https://docs.github.com
- Git Guide: https://git-scm.com/book/en/v2

---

**Congratulations!** Your Pi-hole Plasma Widget is now on GitHub! 🎉
