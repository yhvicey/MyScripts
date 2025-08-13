param(
    [switch]$SkipChocolatey = $false,
    [switch]$SkipWinget = $false
)

$Script:ErrorActionPreference = "Stop"

EnsureAdminPrivileges;

if (-not $ToolsFolder) {
    Write-Error "Tools folder not defined, run SetupEnvironment.ps1 first.";
    exit;
}

if (-not $SkipChocolatey) {
    #
    # Chocolatey
    #

    # Install choco.exe if not installed
    $chocoExe = (Get-Command "choco" -ErrorAction SilentlyContinue).Path;
    if (($null -eq $chocoExe) -or -not (Test-Path $chocoExe)) {
        Write-Host "choco.exe not found, install it...";
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
}

if (-not $SkipWinget) {
    #
    # Winget
    #

    $wingetExe = (Get-Command "winget" -ErrorAction SilentlyContinue).Path;
    if (Test-Path $wingetExe) {
        # Install winget tools
        foreach ($wingetToolInstallExp in (Get-Content "$PSScriptRoot/winget.tools")) {
            $parts = $wingetToolInstallExp -split ',';
            $wingetPackageId = $parts[0]
            $additionalArgs = $parts[1]
            $installExpression = "& $wingetExe install --accept-package-agreements --exact --id $wingetPackageId $additionalArgs";
            Write-Host "Running: $installExpression"
            Invoke-Expression $installExpression
        }
    }
    else {
        Write-Host "winget.exe not found, skipping install winget tools"
    }
}

#region Post setup
Write-Host "Tools setup done."
#endregion
