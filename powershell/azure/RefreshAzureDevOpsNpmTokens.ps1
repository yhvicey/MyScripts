function RefreshAzureDevOpsNpmTokens(
    [string]$EnvironmentVariable = "NPM_TOKEN",
    [switch]$SetEnvironmentVariable = $false,
    [System.EnvironmentVariableTarget] $Target = [EnvironmentVariableTarget]::User
) {
    $script:ErrorActionPreference = "Stop"
    $npmrcFile = "$HOME/.npmrc"
    if (-not (Test-Path $npmrcFile)) {
        Write-Warning "Npm settings file ($npmrcFile) not found."
        return
    }
    $token = GetAzureDevOpsToken
    $newLines = @()
    foreach ($line in Get-Content $npmrcFile) {
        $isAdoLine = $line.StartsWith("//pkgs.dev.azure.com") -or $line -match "^//(\w+).pkgs.visualstudio.com"
        $isAuthTokenLine = $line.Contains(":_authToken=")
        if ($isAdoLine -and $isAuthTokenLine) {
            $lineBreakIdx = $line.IndexOf(":_authToken=")
            $registry = $line.SubString(0, $lineBreakIdx)
            Write-Host "Updating auth token for $registry"
            $line = "$($registry):_authToken=$token"
        }
        $newLines += $line
    }
    Set-Content $npmrcFile $newLines

    if ($SetEnvironmentVariable) {
        [System.Environment]::SetEnvironmentVariable($EnvironmentVariable, $token.ToString(), $Target)
        refreshenv
    }
}
Set-Alias "rant" "RefreshAzureDevOpsNpmTokens"