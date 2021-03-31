$Script:ErrorActionPreference = "Stop"

EnsureAdminPrivileges;

if (-not $ToolsFolder) {
    Write-Error "Tools folder not defined, run SetupEnvironment.ps1 first.";
    exit;
}

# Install choco.exe if not installed
$chocoExe = (Get-Command "choco" -ErrorAction SilentlyContinue).Path;
if (($null -eq $chocoExe) -or -not (Test-Path $chocoExe)) {
    $chocolateyInstall = "$ToolsFolder\chocolatey";
    Write-Host "choco.exe not found, install it to $chocolateyInstall...";
    [System.Environment]::SetEnvironmentVariable("ChocolateyInstall", $chocolateyInstall, "Machine");
    $env:ChocolateyInstall = $chocolateyInstall;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));
    $chocoExe = (Get-Command "choco").Path;
    & $chocoExe feature enable -n allowGlobalConfirmation;
}

# Install tools
& $chocoExe install "$PSScriptRoot/tools.config";

#region Post setup
Write-Host "Tools setup done."
# Create other folders
if (-not (Test-Path "$ToolsFolder/bin")) {
    New-Item "$ToolsFolder/bin" -ItemType Directory | Out-Null;
}
#endregion
