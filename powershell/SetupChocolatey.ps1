EnsureAdminPrivileges;

#region Collect input
if (-not $ToolsFolder) {
    $ToolsFolder = Read-Host -Prompt "Input chocolatey tools folder path [D:/Tools]";
}
if (-not $ToolsFolder) {
    $ToolsFolder = "D:/Tools";
}
$ToolsFolder = $ToolsFolder.TrimEnd("/").TrimEnd("\");
if (-not (Test-Path $ToolsFolder)) {
    New-Item $ToolsFolder -ItemType Directory | Out-Null;
}
#endregion

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
& $chocoExe install "$PSScriptRoot/win32nt/tools.config";