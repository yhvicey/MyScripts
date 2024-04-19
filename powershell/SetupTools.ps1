$Script:ErrorActionPreference = "Stop"

EnsureAdminPrivileges;

if (-not $ToolsFolder) {
    Write-Error "Tools folder not defined, run SetupEnvironment.ps1 first.";
    exit;
}

#
# Chocolatey
#

# Install choco.exe if not installed
$chocoExe = (Get-Command "choco" -ErrorAction SilentlyContinue).Path;
if (($null -eq $chocoExe) -or -not (Test-Path $chocoExe)) {
    $chocolateyInstall = [System.Environment]::GetEnvironmentVariable("ChocolateyInstall", "Machine")
    if ([string]::IsNullOrEmpty($chocolateyInstall)) {
        $chocolateyInstall = "$ToolsFolder\chocolatey";
    }
    else {
        Write-Host "Picking ChocolateyInstall from existing environment variable"
    }
    Write-Host "choco.exe not found, install it to $chocolateyInstall...";
    [System.Environment]::SetEnvironmentVariable("ChocolateyInstall", $chocolateyInstall, "Machine");
    $env:ChocolateyInstall = $chocolateyInstall;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));
    $chocoExe = (Get-Command "choco").Path;
}
$confirmationEnabled = (& $chocoExe feature get allowGlobalConfirmation --limit-output | ForEach-Object { $_ -eq "Enabled" })
if (-not $confirmationEnabled) {
    if (Confirm "Enable Global Confirmation?") {
        & $chocoExe feature enable -n allowGlobalConfirmation;
    }
}

# Try upgrade chocolatey
& $chocoExe upgrade chocolatey

# Install chocolatey tools
foreach ($chocoToolInstallExp in (Get-Content "$PSScriptRoot/choco.tools")) {
    $installExpression = "& $chocoExe upgrade --install-if-not-installed $chocoToolInstallExp";
    Write-Host "Running: $installExpression"
    Invoke-Expression $installExpression
}

#
# Winget
#

$wingetExe = (Get-Command "winget" -ErrorAction SilentlyContinue).Path;
if (Test-Path $wingetExe) {
    # Install winget tools
    foreach ($wingetToolInstallExp in (Get-Content "$PSScriptRoot/winget.tools")) {
        $installExpression = "& $wingetExe install --exact --id --accept-package-agreements $wingetToolInstallExp";
        Write-Host "Running: $installExpression"
        Invoke-Expression $installExpression
    }
}
else {
    Write-Host "winget.exe not found, skipping install winget tools"
}

#region Post setup
Write-Host "Tools setup done."
#endregion
