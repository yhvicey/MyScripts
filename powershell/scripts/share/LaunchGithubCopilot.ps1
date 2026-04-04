param(
    [string]$Session = $null
)

$ghcArgs = @()

if (-not [string]::IsNullOrEmpty($Session)) {
    $ghcArgs += "--resume=$Session"
}

$ghcArgs += @("--autopilot", "--allow-all")

Invoke-Expression "copilot $ghcArgs"