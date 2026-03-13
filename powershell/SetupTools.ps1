param(
    [string]$SkipTo = $null,
    [switch]$SkipWinget = $false,
    [switch]$SkipChocolatey = $false,
    [switch]$EditWingetList = $false,
    [switch]$EditChocolateyList = $false
)

$SkipToParam = $SkipTo

if ($EditWingetList) {
    code "$PSScriptRoot/winget.tools"
    return;
}

if ($EditChocolateyList) {
    code "$PSScriptRoot/choco.tools"
    return;
}

$Script:ErrorActionPreference = "Stop"

EnsureAdminPrivileges;

if (-not $ToolsFolder) {
    Write-Error "Tools folder not defined, run SetupEnvironment.ps1 first.";
    return;
}

if (-not $SkipWinget) {
    #
    # Winget
    #

    $wingetExe = (Get-Command "winget" -ErrorAction SilentlyContinue).Path;
    if (Test-Path $wingetExe -ErrorAction SilentlyContinue) {
        # Install winget tools
        foreach ($wingetToolInstallExp in (Get-Content "$PSScriptRoot/winget.tools")) {
            $parts = $wingetToolInstallExp -split '\t';
            $wingetPackageId = $parts[0]
            $additionalArgs = $parts[1]

            if (-not [string]::IsNullOrEmpty($SkipTo) -and $SkipTo -ne $wingetPackageId) {
                Write-Host "Skipping $wingetPackageId, not reached skip-to package $SkipTo yet."
                continue;
            }
            else {
                $SkipTo = $null; # reset skip-to after reaching the package
            }

            $installExpression = "& $wingetExe install --accept-package-agreements --exact --id $wingetPackageId $additionalArgs";
            Write-Host "Running: $installExpression"
            Invoke-Expression $installExpression
        }
    }
    else {
        Write-Host "winget.exe not found, skipping install winget tools"
    }
}

$SkipTo = $SkipToParam

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
        $parts = $chocoToolInstallExp -split '\t';
        $chocoPackageId = $parts[0]

        if (-not [string]::IsNullOrEmpty($SkipTo) -and $SkipTo -ne $chocoPackageId) {
            Write-Host "Skipping $chocoPackageId, not reached skip-to package $SkipTo yet."
            continue;
        }
        else {
            $SkipTo = $null; # reset skip-to after reaching the package
        }

        $installExpression = "& $chocoExe upgrade --install-if-not-installed $chocoPackageId";
        Write-Host "Running: $installExpression"
        Invoke-Expression $installExpression
    }
}

#region Post setup
Write-Host "Tools setup done."
#endregion
