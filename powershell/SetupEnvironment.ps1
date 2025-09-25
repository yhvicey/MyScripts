#!/usr/bin/env pwsh
param(
    [switch]$SkipInstallPhase = $false
)

#region Collect input
if (-not $DevFolder) {
    $DevFolder = Read-Host -Prompt "Input development folder path [D:/Dev]";
}
if (-not $DevFolder) {
    $DevFolder = "D:/Dev";
}
$DevFolder = $DevFolder.TrimEnd("/").TrimEnd("\");
[System.Environment]::SetEnvironmentVariable("DEV_HOME", $DevFolder, [System.EnvironmentVariableTarget]::User)
if (-not (Test-Path $DevFolder)) {
    New-Item $DevFolder -ItemType Directory | Out-Null;
}
if (-not $ToolsFolder) {
    $ToolsFolder = Read-Host -Prompt "Input tools folder path [$HOME/Tools]";
}
if (-not $ToolsFolder) {
    $ToolsFolder = "$HOME/Tools";
}
$ToolsFolder = $ToolsFolder.TrimEnd("/").TrimEnd("\");
if (-not (Test-Path $ToolsFolder)) {
    New-Item $ToolsFolder -ItemType Directory | Out-Null;
}
#endregion

#region Setup powershell
$profileFolder = Split-Path $PROFILE -Parent
if (-not (Test-Path $profileFolder)) {
    New-Item -Path $profileFolder -ItemType Directory -Force | Out-Null
}
$startupScript = "$profileFolder/Startup.ps1"
$startupDoneFile = "$profileFolder/Startup.done"
$MyScriptsRoot = Resolve-Path "$PSScriptRoot/.."
# Install profile
$startupScriptContent = Get-Content "$PSScriptRoot/Startup.ps1" -Raw;
$startupScriptContent = $startupScriptContent.Replace("<MyScriptsRoot>", $MyScriptsRoot);
$startupScriptContent = $startupScriptContent.Replace("<DevFolder>", $DevFolder);
$startupScriptContent = $startupScriptContent.Replace("<ToolsFolder>", $ToolsFolder);
$setupFlag = "MY_SCRIPTS_SETUP_DONE"
$startupScriptContent | Out-File -NoNewline -Force $startupScript;
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
if (Test-Path $PROFILE) {
    Get-Content $PROFILE | Where-Object { -not $_.Contains($setupFlag) } | Out-File -NoNewline -Force $PROFILE;
}
else {
    New-Item $PROFILE -ItemType File -Force;
}
Write-Output ". '$startupScript' # $setupFlag" >> $PROFILE;
Push-Location $MyScriptsRoot
try {
    $repoVersion = git rev-parse master
}
catch {
    $repoVersion = "ERROR_GETTING_VERSION"
}
finally {
    Pop-Location
}
Write-Output $repoVersion > $startupDoneFile
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
# Set environment varibales
[Environment]::SetEnvironmentVariable("Workspace", $Workspace, [System.EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("Playground", $Playground, [System.EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("GithubRepos", $GithubRepos, [System.EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("TempDirs", $TempDirs, [System.EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("ToolsBinFolder", $ToolsBinFolder, [System.EnvironmentVariableTarget]::User)
#endregion
