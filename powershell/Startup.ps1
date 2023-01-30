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
$versionFile = "~/Startup.done"
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
    Write-Warning "Installed scripts can be upgraded, continue? [Y(es)/f(ull)/n(o)]"
    $confirm = [Console]::ReadKey()
    if ([Char]::ToLower($confirm.KeyChar) -eq "y") {
        & "$MyScriptsRoot/powershell/SetupEnvironment.ps1" -SkipInstallPhase
    }
    elseif ([Char]::ToLower($confirm.KeyChar) -eq "f") {
        & "$MyScriptsRoot/powershell/SetupEnvironment.ps1"
    }
}

#endregion

#region Load scripts & modules
$foldersToLoadScriptsFrom = @(
    "$MyScriptsRoot/powershell/core",
    "$MyScriptsRoot/powershell/share",
    "$MyScriptsRoot/powershell/$($CurrentOS.ToLower())"
);
foreach ($folder in $foldersToLoadScriptsFrom) {
    if (-not (Test-Path $folder)) {
        continue;
    }
    foreach ($scriptPath in (Get-ChildItem -Recurse $folder -Filter "*.ps1")) {
        try {
            Write-Debug "Loading $($scriptPath.FullName)";
            . $scriptPath.FullName;
        }
        catch {
            Write-Warning "Failed to load $($scriptPath.FullName), error: $_";
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
