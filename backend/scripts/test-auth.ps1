# Test auth endpoints with POST. Run from backend folder.
# Usage: .\scripts\test-auth.ps1

$base = "http://localhost:4000"
$email = "test@example.com"

Write-Host "1. Request OTP (POST)..." -ForegroundColor Cyan
$r = Invoke-RestMethod -Method Post -Uri "$base/api/auth/request-otp" -ContentType "application/json" -Body (@{ email = $email } | ConvertTo-Json)
Write-Host "   Success. Response:" $r
$otp = $r.data.otp
if (-not $otp) { Write-Host "   (No OTP in response - set NODE_ENV or check backend)" }

Write-Host "`n2. Verify OTP (POST) - need the 6-digit code from step 1 or response..." -ForegroundColor Cyan
if ($otp) {
  $v = Invoke-RestMethod -Method Post -Uri "$base/api/auth/verify-otp" -ContentType "application/json" -Body (@{ email = $email; otp = $otp } | ConvertTo-Json)
  Write-Host "   Success. Token received:" $v.data.token.Substring(0, [Math]::Min(50, $v.data.token.Length)) "..."
} else {
  Write-Host "   Skipped (no OTP). Run step 1 in dev mode to get OTP in response, or check email."
}

Write-Host "`nDone. If both steps worked, backend is fine. Use the app for login (it sends POST)." -ForegroundColor Green
