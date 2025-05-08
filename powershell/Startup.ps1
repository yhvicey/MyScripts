#region Global variables
# Folders
$global:MyScriptsRoot = "<MyScriptsRoot>";
$global:DevFolder = "<DevFolder>";
$global:Workspace = "$DevFolder/Workspace";
$global:Playground = "$DevFolder/Playground";
$global:GithubRepos = "$DevFolder/Github";
$global:ToolsFolder = "<ToolsFolder>";
$global:ToolsBinFolder = "$ToolsFolder/bin";
$global:Desktop = "$([Environment]::GetFolderPath("desktop"))";
$global:TempDirs = "$Desktop/tempDirs";

# Others
$global:CurrentOS = [System.Environment]::OSVersion.Platform.ToString();
#endregion

#region Version check
$profileFolder = Split-Path $PROFILE -Parent
$versionFile = "$profileFolder/Startup.done"
if (Test-Path $versionFile) {
    $currentVersion = [string](Get-Content $versionFile)
}
Push-Location $MyScriptsRoot
try {
    $repoVersion = git rev-parse master
}
catch {}
finally {
    Pop-Location
}
if ($repoVersion -ne $currentVersion) {
    & "$MyScriptsRoot/powershell/SetupEnvironment.ps1" -SkipInstallPhase
}
#endregion

#region Load scripts & modules
. "$MyScriptsRoot/powershell/scripts/Core.ps1"
$foldersToLoadScriptsFrom = @(
    "$MyScriptsRoot/powershell/scripts/share",
    "$MyScriptsRoot/powershell/scripts/$($CurrentOS.ToLower())"
    "$MyScriptsRoot/powershell/scripts/private"
);
$autoLoadScripts = @(
    "Aliases.ps1",
    "Paths.ps1",
    "Shortcuts.ps1",
    "Startup.ps1"
)
foreach ($folder in $foldersToLoadScriptsFrom) {
    if (-not (Test-Path $folder)) {
        continue;
    }
    AddToPath $folder;
    foreach ($autoLoadScript in $autoLoadScripts) {
        if (Test-Path "$folder/$autoLoadScript") {
            try {
                Write-Debug "Loading $autoLoadScript for $folder";
                . "$folder/$autoLoadScript";
            }
            catch {
                Write-Warning "Failed to load $autoLoadScript for $folder, error: $_";
            }
        }
    }
}
foreach ($module in (Get-Content "$MyScriptsRoot/powershell/modules/powershell")) {
    Write-Debug "Importing $module";
    Import-Module $module;
}
foreach ($module in (Get-ChildItem "$MyScriptsRoot/powershell/modules" -Directory)) {
    if (Test-Path "$($module.FullName)/Startup.ps1") {
        Write-Debug "Importing $($module.Name)";
        & "$($module.FullName)/Startup.ps1"
    }
    else {
        Write-Debug "No startup file found for $module"
    }
}
#endregion
