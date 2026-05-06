param(
    [string]$Session = $null
)

$ocArgs = @()

if (-not [string]::IsNullOrEmpty($Session)) {
    $ocArgs += "--session"
    $ocArgs += $Session
}

Invoke-Expression "opencode $ocArgs"