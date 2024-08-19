function SetupNpmAzureDevOpsAuth(
    [string]$LocalNpmrcFile = ".npmrc"
) {
    $script:ErrorActionPreference = "Stop"
    $globalNpmrcFile = "$HOME/.npmrc"
    if (-not (Test-Path $LocalNpmrcFile)) {
        Write-Warning "Npm settings file ($LocalNpmrcFile) not found."
        return
    }
    $registry = ""
    foreach ($line in Get-Content $LocalNpmrcFile) {
        if ($line.StartsWith("registry=")) {
            $registry = $line.Substring(9)
        }
    }

    if ([string]::IsNullOrEmpty($registry)) {
        Write-Error "Registry not found in $LocalNpmrcFile"
        return
    }

    $key = $registry.Replace("https:", "").Replace("/registry/", "/") + ":_authToken"
    $token = GetAzureDevOpsToken

    $added = $false
    $newLines = @()
    foreach ($line in Get-Content $globalNpmrcFile) {
        if ($line.StartsWith($key)) {
            $line = "$key=$token"
            $added = $true
        }
        $newLines += $line
    }
    if (-not $added) {
        $newLines += "$key=$token"
    }
    Set-Content $globalNpmrcFile $newLines
}