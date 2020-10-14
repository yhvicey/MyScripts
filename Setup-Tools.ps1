if (-not $global:ToolsFolder) {
    Write-Warning "Environment is not set up yet, please run Setup-Environment.ps1 first.";
    exit 1;
}

EnsureAdminPrivileges;

$ToolsFolder = $global:ToolsFolder.TrimEnd("/").TrimEnd("\");
if (-not (Test-Path $ToolsFolder)) {
    New-Item $ToolsFolder -ItemType Directory | Out-Null;
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
& $chocoExe install "$PSScriptRoot/misc/tools.config";