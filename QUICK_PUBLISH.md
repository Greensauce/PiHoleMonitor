# 🚀 Quick Publish to GitHub

Three easy ways to publish your Pi-hole Plasma Widget to GitHub!

---

## Method 1: Automated Script (Easiest!) ⭐

```bash
cd /path/to/github-repo
./create-github-repo.sh
```

The script will:
- ✅ Update all links with your GitHub username
- ✅ Initialize git repository
- ✅ Create first commit
- ✅ Guide you through creating the GitHub repository
- ✅ Push to GitHub

**Just follow the prompts!**

---

## Method 2: Manual (Step-by-Step)

### Step 1: Create Repository on GitHub

1. Go to https://github.com/new
2. Settings:
   - **Name**: `pihole-plasma-widget`
   - **Description**: `KDE Plasma 6 widget for monitoring and controlling Pi-hole`
   - **Public** ✓
   - **DO NOT** check any initialization boxes
3. Click **Create repository**

### Step 2: Prepare Local Repository

```bash
cd /path/to/github-repo

# Update links (replace YOUR-USERNAME with your actual username)
find . -type f -name "*.md" -exec sed -i 's/YOUR_USERNAME/YOUR-USERNAME/g' {} +

# Initialize git
git init
git add .
git commit -m "Initial commit - Pi-hole Plasma Widget v2.7.1"
git branch -M main
```

### Step 3: Push to GitHub

```bash
# Add remote (replace YOUR-USERNAME)
git remote add origin https://github.com/YOUR-USERNAME/pihole-plasma-widget.git

# Push
git push -u origin main
```

---

## Method 3: Using GitHub CLI (for advanced users)

If you have GitHub CLI installed:

```bash
cd /path/to/github-repo

# Update links
find . -type f -name "*.md" -exec sed -i 's/YOUR_USERNAME/YOUR-USERNAME/g' {} +

# Initialize
git init
git add .
git commit -m "Initial commit - Pi-hole Plasma Widget v2.7.1"

# Create and push (GitHub CLI will create the repo)
gh repo create pihole-plasma-widget --public --source=. --remote=origin --push

# Set description
gh repo edit --description "KDE Plasma 6 widget for monitoring and controlling Pi-hole"

# Add topics
gh repo edit --add-topic kde-plasma,plasma-widget,pihole,plasma6,kde,qml
```

---

## After Publishing

### 1. Configure Repository

Go to your repository → Settings → About:
- Add topics: `kde-plasma`, `plasma-widget`, `pihole`, `plasma6`, `kde`, `qml`
- Add website (if you have one)

### 2. Create First Release

1. Go to: https://github.com/YOUR-USERNAME/pihole-plasma-widget/releases/new
2. Click "Choose a tag" → type `v2.7.1` → Create new tag
3. Release title: `v2.7.1 - Stable Release`
4. Description: Copy from CHANGELOG.md
5. Upload: `pihole-plasma-widget.tar.gz` (from parent directory)
6. Click **Publish release**

### 3. Add Screenshots

```bash
# Take screenshots of the widget
# Save to docs/screenshots/

git add docs/screenshots/*.png
git commit -m "Add screenshots"
git push
```

### 4. Share Your Widget! 🎉

- **Reddit**: /r/kde, /r/pihole, /r/selfhosted
- **KDE Forums**: Plasma section
- **Pi-hole Discourse**: Community
- **Twitter/Mastodon**: Use #KDE #Plasma #PiHole

---

## Need Help?

- **Detailed Guide**: See `GITHUB_SETUP.md`
- **GitHub Docs**: https://docs.github.com
- **Git Tutorial**: https://git-scm.com/book

---

## Quick Checklist

After publishing, verify:

- [ ] Repository is public
- [ ] README displays correctly
- [ ] Topics/tags are added
- [ ] First release is created (v2.7.1)
- [ ] Installation instructions work
- [ ] All links work (no YOUR_USERNAME placeholders)
- [ ] License is visible

---

**Choose Method 1 (Automated Script) if you're new to GitHub!**

**Questions?** Check `GITHUB_SETUP.md` for complete instructions.

Good luck! 🚀
