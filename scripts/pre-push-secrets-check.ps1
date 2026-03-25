# Simple pre-push secrets check. Use when git-secrets is not installed.
# Install: copy this to your repo's .git/hooks/pre-push and chmod +x (or run via PowerShell).
# Usage from repo root: .\scripts\pre-push-secrets-check.ps1

$ErrorActionPreference = "Stop"
$patterns = @(
    'sk_live_[a-zA-Z0-9]{20,}',
    'sk_test_[a-zA-Z0-9]{20,}',
    'AIza[0-9A-Za-z\-_]{35}',   # Firebase/Google API key pattern
    '["'']sk_live_',
    '["'']sk_test_'
)
$found = $false
$repoRoot = if ($env:GIT_DIR) { Split-Path $env:GIT_DIR } else { git rev-parse --show-toplevel }
if (-not $repoRoot) { exit 0 }
Push-Location $repoRoot
try {
    $files = git diff --name-only --cached
    if ($files) {
        foreach ($f in $files) {
            if (-not (Test-Path $f) -or (Get-Item $f) -is [System.IO.DirectoryInfo]) { continue }
            $content = Get-Content -Raw -Path $f -ErrorAction SilentlyContinue
            if (-not $content) { continue }
            foreach ($pat in $patterns) {
                if ($content -match $pat) {
                    Write-Host "SECRETS CHECK FAILED: Possible secret in $f (pattern: $pat)" -ForegroundColor Red
                    $found = $true
                }
            }
        }
    }
    if ($found) {
        Write-Host "Remove secrets before pushing. See docs/GIT_SECRETS_SETUP.md" -ForegroundColor Yellow
        exit 1
    }
} finally {
    Pop-Location
}
exit 0
