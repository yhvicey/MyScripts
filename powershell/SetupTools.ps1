$Script:ErrorActionPreference = "Stop"

EnsureAdminPrivileges;

if (-not $ToolsFolder) {
    Write-Error "Tools folder not defined, run SetupEnvironment.ps1 first.";
    exit;
}

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
    & $chocoExe feature enable -n allowGlobalConfirmation;
}

# Install tools
foreach ($chocoToolInstallExp in (Get-Content "$PSScriptRoot/choco.tools")) {
    $installExpression = "& $chocoExe upgrade --install-if-not-installed $chocoToolInstallExp";
    Write-Host "Running: $installExpression"
    Invoke-Expression $installExpression
}

#region Post setup
Write-Host "Tools setup done."
#endregion
