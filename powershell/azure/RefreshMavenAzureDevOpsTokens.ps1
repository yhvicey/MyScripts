function RefreshMavenAzureDevOpsTokens(
    [string]$EnvironmentVariable = "MAVEN_TOKEN",
    [switch]$SetEnvironmentVariable = $false,
    [System.EnvironmentVariableTarget] $Target = [EnvironmentVariableTarget]::User
) {
    $script:ErrorActionPreference = "Stop"
    $m2File = "$HOME/.m2/settings.xml"
    if (-not (Test-Path $m2File)) {
        Write-Warning "Maven settings file ($m2File) not found."
        return
    }
    $token = GetAzureDevOpsToken
    [xml]$cfg = Get-Content $m2File
    $cfg.settings.servers.server | ForEach-Object {
        $_.password = $token.ToString()
    }
    $cfg.Save($m2File);

    if ($SetEnvironmentVariable) {
        [System.Environment]::SetEnvironmentVariable($EnvironmentVariable, $token.ToString(), $Target)
        refreshenv
    }
}