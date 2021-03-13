#!/usr/bin/env pwsh

#region Collect input
if (-not $DevFolder) {
    $DevFolder = Read-Host -Prompt "Input development folder path [D:/Dev]";
}
if (-not $DevFolder) {
    $DevFolder = "D:/Dev";
}
$DevFolder = $DevFolder.TrimEnd("/").TrimEnd("\");
if (-not (Test-Path $DevFolder)) {
    New-Item $DevFolder -ItemType Directory | Out-Null;
}
if (-not $ToolsFolder) {
    $ToolsFolder = Read-Host -Prompt "Input tools folder path [D:/Tools]";
}
if (-not $ToolsFolder) {
    $ToolsFolder = "D:/Tools";
}
$ToolsFolder = $ToolsFolder.TrimEnd("/").TrimEnd("\");
if (-not (Test-Path $ToolsFolder)) {
    New-Item $ToolsFolder -ItemType Directory | Out-Null;
}
#endregion

#region Setup powershell
$startupScript = "~/startup.ps1"
# Install profile
$startupScriptContent = Get-Content "$PSScriptRoot/startup.ps1" -Raw;
$startupScriptContent = $startupScriptContent.Replace("<MyScriptsRoot>", $PSScriptRoot);
$startupScriptContent = $startupScriptContent.Replace("<DevFolder>", $DevFolder);
$startupScriptContent = $startupScriptContent.Replace("<ToolsFolder>", $ToolsFolder);
$setupFlag = "MY_SCRIPTS_SETUP_DONE"
$startupScriptContent | Out-File -NoNewline -Force $startupScript;
# Install modules
if ((Get-PSRepository PSGallery).InstallationPolicy -ne "Trusted") {
    Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted"
}
foreach ($module in (Get-Content "$PSScriptRoot/modules")) {
    if ($null -eq (Get-InstalledModule $module -ErrorAction SilentlyContinue)) {
        Write-Host "Installing $module...";
        Install-Module $module;
    } else {
        Write-Host "Updating $module...";
        Update-Module -Name $module;
    }
}
# Setup profile
if (Test-Path $PROFILE) {
    Get-Content $PROFILE | Where-Object { -not $_.Contains($setupFlag) } | Out-File -NoNewline -Force $PROFILE;
}
else {
    New-Item $PROFILE -ItemType File -Force;
}
Write-Output ". $startupScript # $setupFlag" >> $PROFILE;
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
#endregion
