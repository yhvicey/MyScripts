function SetupMavenAuth(
    [string]$EnvironmentVariable = "MAVEN_TOKEN",
    [switch]$SetEnvironmentVariable = $false,
    [System.EnvironmentVariableTarget] $Target = [EnvironmentVariableTarget]::User
) {
    $script:ErrorActionPreference = "Stop"
    $token = az account get-access-token `
        --scope "499b84ac-1321-427f-aa17-267ca6975798/.default" `
        --query accessToken `
        -o tsv
    [xml]$cfg = Get-Content "$HOME/.m2/settings.xml"
    $cfg.settings.servers.server | ForEach-Object {
        $_.password = $token.ToString()
    }
    $cfg.Save("$HOME/.m2/settings.xml");

    if ($SetEnvironmentVariable) {
        [System.Environment]::SetEnvironmentVariable($EnvironmentVariable, $token.ToString(), $Target)
        refreshenv
    }
}