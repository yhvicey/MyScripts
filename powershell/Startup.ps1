#region Global variables
# Folders
$global:MyScriptsRoot = "$env:MY_SCRIPTS_ROOT";
$global:DevFolder = "$env:DEV_HOME";
$global:Workspace = "$DevFolder/Workspace";
$global:Playground = "$DevFolder/Playground";
$global:GithubRepos = "$DevFolder/Github";
$global:TempDirs = "$DevFolder/Temp";
$global:ToolsFolder = "$env:TOOLS_HOME";
$global:ToolsBinFolder = "$ToolsFolder/bin";
$global:Desktop = "$([Environment]::GetFolderPath("desktop"))";

# Others
$global:CurrentOS = [System.Environment]::OSVersion.Platform.ToString();
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
    "Startup.ps1",
    "Check.ps1"
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
