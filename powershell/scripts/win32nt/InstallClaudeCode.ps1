param(
    [string]$Version = $null
)

if ([string]::IsNullOrEmpty($Version)) {
    $Version = "latest"
    $DisableAutoupdater = $false
}
else {
    $DisableAutoupdater = $true
}

# Persist (or remove) the auto-updater disable setting in the global settings file
$settingsPath = "$env:USERPROFILE\.claude\settings.json"

if (Test-Path $settingsPath) {
    $settingsJson = Get-Content -Path $settingsPath -Raw
    $settings = $settingsJson | ConvertFrom-Json
}
else {
    $settings = [PSCustomObject]@{}
}

if ($DisableAutoupdater) {
    # Ensure the env property exists, then set DISABLE_AUTOUPDATER = 1
    if ($null -eq $settings.env) {
        $settings | Add-Member -MemberType NoteProperty -Name 'env' -Value ([PSCustomObject]@{})
    }
    if ($settings.env.PSObject.Properties['DISABLE_AUTOUPDATER']) {
        $settings.env.DISABLE_AUTOUPDATER = 1
    }
    else {
        $settings.env | Add-Member -MemberType NoteProperty -Name 'DISABLE_AUTOUPDATER' -Value 1
    }
}
else {
    # Remove DISABLE_AUTOUPDATER if present, leaving other env keys untouched
    if ($null -ne $settings.env -and $settings.env.PSObject.Properties['DISABLE_AUTOUPDATER']) {
        $settings.env.PSObject.Properties.Remove('DISABLE_AUTOUPDATER')
    }
}

$settingsDir = Split-Path $settingsPath -Parent
if (-not (Test-Path $settingsDir)) {
    New-Item -ItemType Directory -Path $settingsDir | Out-Null
}
$settings | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsPath -Encoding UTF8

$script = Invoke-RestMethod https://claude.ai/install.ps1
$exp = "function InstallClaudeCode{$script}; InstallClaudeCode '$Version'"
Invoke-Expression $exp
