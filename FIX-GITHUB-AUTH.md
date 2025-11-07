# Fix GitHub Authentication Issue

You're currently authenticated with the wrong GitHub account. Here's how to fix it:

## Option 1: Use GitHub Desktop (Easiest)

1. Download GitHub Desktop: https://desktop.github.com/
2. Sign in with your DigitalExpart account
3. Add this repository (File → Add Local Repository)
4. Push your changes

## Option 2: Use Git Credential Manager (Recommended)

```powershell
# Clear cached credentials
git credential-manager-core erase https://github.com

# Or use this command
cmdkey /delete:LegacyGeneric:target=git:https://github.com

# Then push again - it will ask for credentials
git push
```

When prompted, log in with your **DigitalExpart** account credentials.

## Option 3: Use Personal Access Token

### Create a Personal Access Token:

1. Go to: https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Name: `Voiceflow API`
4. Expiration: 90 days (or your choice)
5. Scopes: Check ✓ **repo** (full control)
6. Click "Generate token"
7. **Copy the token** (you won't see it again!)

### Update Git remote with token:

```powershell
# Remove current remote
git remote remove origin

# Add new remote with your token
git remote add origin https://YOUR_TOKEN@github.com/DigitalExpart/Serverless-Voiceflow-Integration.git

# Push
git push -u origin main
```

Replace `YOUR_TOKEN` with the token you copied.

## Verify Your Current Git User

```powershell
# Check current Git user
git config user.name
git config user.email

# If wrong, update them:
git config user.name "DigitalExpart"
git config user.email "your-email@example.com"
```

## After Authentication Works

Once you've authenticated correctly, run:

```powershell
git push
```

Your changes will be pushed to GitHub!

---

**Note**: The commit is already saved locally. Once you fix authentication, just run `git push` to upload everything.

