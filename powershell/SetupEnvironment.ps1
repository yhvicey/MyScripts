#!/usr/bin/env pwsh
param(
    [switch]$SkipInstallPhase = $false,
    [switch]$ReCollectInputs = $false
)

if (Test-Path "D:\") {
    $eligibleDrive = "D:"
}
else {
    $eligibleDrive = "C:"
}

#region Collect input
$proposedDevFolder = (Resolve-Path "$eligibleDrive/Dev").Path
if ($ReCollectInputs -or -not $DevFolder) {
    $DevFolder = Read-Host -Prompt "Input development folder path [$proposedDevFolder]";
}
if (-not $DevFolder) {
    $DevFolder = $proposedDevFolder;
}
$DevFolder = $DevFolder.TrimEnd("/").TrimEnd("\");
if (-not (Test-Path $DevFolder)) {
    New-Item $DevFolder -ItemType Directory | Out-Null;
}

$proposedToolsFolder = (Resolve-Path "$HOME/Tools").Path
if ($ReCollectInputs -or -not $ToolsFolder) {
    $ToolsFolder = Read-Host -Prompt "Input tools folder path [$proposedToolsFolder]";
}
if (-not $ToolsFolder) {
    $ToolsFolder = $proposedToolsFolder;
}
$ToolsFolder = $ToolsFolder.TrimEnd("/").TrimEnd("\");
if (-not (Test-Path $ToolsFolder)) {
    New-Item $ToolsFolder -ItemType Directory | Out-Null;
}

$MyScriptsRoot = Resolve-Path "$PSScriptRoot/.."
#endregion

#region Setup powershell
$profileFolder = Split-Path $PROFILE -Parent
if (-not (Test-Path $profileFolder)) {
    New-Item -Path $profileFolder -ItemType Directory -Force | Out-Null
}
# Install profile
if (-not $SkipInstallPhase) {
    if (-not (Get-PSRepository PSGallery -ErrorAction SilentlyContinue)) {
        Register-PSRepository -Default
    }
    # Install modules
    if ((Get-PSRepository PSGallery).InstallationPolicy -ne "Trusted") {
        Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted"
    }
    foreach ($module in (Get-Content "$PSScriptRoot/modules/powershell")) {
        if ($null -eq (Get-InstalledModule $module -ErrorAction SilentlyContinue)) {
            Write-Host "Installing $module...";
            Install-Module $module -Scope CurrentUser -AllowClobber -Force;
        }
        else {
            Write-Host "Updating $module...";
            Update-Module $module;
        }
    }
    foreach ($module in (Get-ChildItem "$PSScriptRoot/modules" -Directory)) {
        $installedPath = "$($module.FullName)/installed"
        $installed = Test-Path $installedPath
        if ($installed) {
            if (-not (Test-Path "$($module.FullName)/skip_upgrade")) {
                $upgradeScript = "$($module.FullName)/Upgrade.ps1"
                if (-not (Test-Path $upgradeScript)) {
                    $upgradeScript = "$($module.FullName)/Install.ps1"
                }
                Write-Host "Upgrading $($module.Name)...";
                & $upgradeScript
            }
            else {
                Write-Host "$($module.Name) already installed and upgrade is skipped";
            }
        }
        elseif (Test-Path "$($module.FullName)/Install.ps1") {
            try {
                Write-Host "Installing $($module.Name)...";
                & "$($module.FullName)/Install.ps1"
                Set-Content $installedPath ([datetime]::UtcNow) -Force
            }
            catch {
                Write-Error "Failed to install module $module"
                Write-Error $_
            }
        }
        else {
            Write-Host "Module $module's install script is not provided, skipping";
        }
    }
}
# Setup profile
$setupFlag = "MY_SCRIPTS_SETUP_DONE"
if (Test-Path $PROFILE) {
    Get-Content $PROFILE | Where-Object { -not $_.Contains($setupFlag) } | Out-File -NoNewline -Force $PROFILE;
}
else {
    New-Item $PROFILE -ItemType File -Force;
}
Write-Output ". '$MyScriptsRoot/powershell/Startup.ps1' # $setupFlag" >> $PROFILE;
#endregion

# Set environment variables
[System.Environment]::SetEnvironmentVariable("DEV_HOME", $DevFolder, [System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable("TOOLS_HOME", $ToolsFolder, [System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable("MY_SCRIPTS_ROOT", $MyScriptsRoot, [System.EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("Workspace", $Workspace, [System.EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("Playground", $Playground, [System.EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("GithubRepos", $GithubRepos, [System.EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("TempDirs", $TempDirs, [System.EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("ToolsBinFolder", $ToolsBinFolder, [System.EnvironmentVariableTarget]::User)
#endregion

#region Post setup
Write-Host "Environment setup done."
. $PROFILE;
# Create other folders
if (-not (Test-Path $Workspace)) {
    New-Item $Workspace -ItemType Directory | Out-Null;
}
if (-not (Test-Path $Playground)) {
    New-Item $Playground -ItemType Directory | Out-Null;
}
if (-not (Test-Path $GithubRepos)) {
    New-Item $GithubRepos -ItemType Directory | Out-Null;
}
if (-not (Test-Path $TempDirs)) {
    New-Item $TempDirs -ItemType Directory | Out-Null;
}
if (-not (Test-Path $ToolsBinFolder)) {
    New-Item $ToolsBinFolder -ItemType Directory | Out-Null;
}
