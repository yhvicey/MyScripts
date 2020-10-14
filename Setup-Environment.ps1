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
# Install profile
$profileContent = Get-Content "$PSScriptRoot/Microsoft.PowerShell_profile.ps1" -Raw;
$profileContent = $profileContent.Replace("<MyScriptsRoot>", $PSScriptRoot);
$profileContent = $profileContent.Replace("<DevFolder>", $DevFolder);
$profileContent = $profileContent.Replace("<ToolsFolder>", $ToolsFolder);
if (-not (Test-Path $PROFILE)) {
    New-Item $PROFILE -ItemType File -Force;
}
$profileContent | Out-File -NoNewline -Force $PROFILE;
# Install modules
if ((Get-PSRepository PSGallery).InstallationPolicy -ne "Trusted") {
    Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted"
}
foreach ($module in (Get-Content "$PSScriptRoot/misc/modules")) {
    if ($null -eq (Get-InstalledModule $module)) {
        Write-Host "Installing $module...";
        Install-Module $module;
    }
}
#endregion

#region Setup paths
foreach ($path in (Get-Content "$PSScriptRoot/misc/paths")) {
    if (-not ($env:PATH.Contains($path))) {
        Write-Host "Adding $path to user's PATH";
        [Environment]::SetEnvironmentVariable(
            "PATH",
            [Environment]::GetEnvironmentVariable("PATH", "User") + ";$path",
            "User")
    }
}
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
#endregion
