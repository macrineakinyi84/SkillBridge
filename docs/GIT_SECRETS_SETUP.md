# Git secrets safety net

Run this setup **before every push** (or once per repo) to avoid committing API keys, passwords, or other secrets.

## 1. Install AWS git-secrets (one-time)

The correct tool is **awslabs/git-secrets**, not the npm package of the same name.

### Windows (PowerShell)

```powershell
# Clone the official repo
git clone https://github.com/awslabs/git-secrets.git
cd git-secrets

# Allow scripts (if needed)
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force

# Install (adds to your PATH)
.\install.ps1
```

### macOS / Linux

```bash
brew install git-secrets   # macOS
# or clone https://github.com/awslabs/git-secrets and run: make install
```

## 2. Install hooks in your repo (one-time per repo)

From your **git repo root** (where `.git` lives):

```bash
git secrets --install
git secrets --register-aws   # catches common AWS key patterns
```

## 3. Add project-specific patterns (recommended)

From the repo root:

```bash
# Stripe secret keys
git secrets --add 'sk_live_[a-zA-Z0-9]+'
git secrets --add 'sk_test_[a-zA-Z0-9]+'

# Generic API key patterns (adjust if too strict)
git secrets --add 'apiKey:\s*['\''\"][^'\''\"]+['\''\"]'
git secrets --add 'api_key\s*=\s*['\''\"][^'\''\"]+['\''\"]'
```

## 4. Scan existing commits (optional)

To check history for leaked secrets:

```bash
git secrets --scan-history
```

## Quick reference

| Command | Purpose |
|--------|--------|
| `git secrets --install` | Install pre-commit hook in current repo |
| `git secrets --register-aws` | Add AWS key patterns |
| `git secrets --add PATTERN` | Add custom forbidden pattern |
| `git secrets --scan` | Scan staged files |
| `git secrets --scan-history` | Scan all history |

After setup, every commit (or push, depending on hook) will block if forbidden patterns are found.
