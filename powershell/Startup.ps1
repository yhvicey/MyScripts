if ($env:ENABLE_DEBUG_LOGGING_IN_STARTUP -eq "1") {
    $DebugPreference = "Continue";
}
if ($env:ENABLE_VERBOSE_LOGGING_IN_STARTUP -eq "1") {
    $DebugPreference = "Continue";
    $VerbosePreference = "Continue";
}

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

function PrintLoadTime([string]$name) {
    $endTs = Get-Date;
    $duration = ($endTs - $script:startTs).TotalMilliseconds;
    if ($duration -gt 1000) {
        Write-Warning "Loaded $name in $duration ms";
    }
    else {
        Write-Debug "Loaded $name in $duration ms";
    }
}

#region Load scripts & modules
$script:startTs = Get-Date;
. "$MyScriptsRoot/powershell/scripts/Core.ps1"
PrintLoadTime "Core.ps1";
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
                $script:startTs = Get-Date;
                . "$folder/$autoLoadScript";
                PrintLoadTime "$autoLoadScript for $folder";
            }
            catch {
                Write-Warning "Failed to load $autoLoadScript for $folder, error: $_";
            }
        }
    }
}
foreach ($module in (Get-Content "$MyScriptsRoot/powershell/modules/powershell")) {
    $script:startTs = Get-Date;
    Import-Module $module;
    PrintLoadTime "module $module";
}
foreach ($module in (Get-ChildItem "$MyScriptsRoot/powershell/modules" -Directory)) {
    if (Test-Path "$($module.FullName)/Startup.ps1") {
        $script:startTs = Get-Date;
        & "$($module.FullName)/Startup.ps1"
        PrintLoadTime "module $($module.Name)";
    }
    else {
        Write-Debug "No startup file found for $module"
    }
}
#endregion

$DebugPreference = "SilentlyContinue";
$VerbosePreference = "SilentlyContinue";