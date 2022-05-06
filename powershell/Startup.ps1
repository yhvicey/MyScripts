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

#region Load scripts & modules
$foldersToLoadScriptsFrom = @(
    "$MyScriptsRoot/core",
    "$MyScriptsRoot/share",
    "$MyScriptsRoot/$($CurrentOS.ToLower())"
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
foreach ($module in (Get-Content "$MyScriptsRoot/modules/powershell")) {
    Write-Debug "Importing $module";
    Import-Module $module;
}
foreach ($module in (Get-ChildItem "$MyScriptsRoot/modules" -Directory)) {
    if (Test-Path "$($module.FullName)/Startup.ps1") {
        Write-Debug "Importing $($module.Name)";
        & "$($module.FullName)/Startup.ps1"
    }
    else {
        Write-Debug "No startup file found for $module"
    }
}
#endregion

#region Settings
# Shell
[console]::InputEncoding = [console]::OutputEncoding = [System.Text.Encoding]::UTF8; # Change code page
Set-PSReadlineKeyHandler -Key Tab -Function Complete # Set bash-style completion
Set-PSReadlineOption -BellStyle None # No bell

# Tools
if (Get-Command "dotnet-suggest" -ErrorAction SilentlyContinue) {
    # dotnet-suggest
    $availableToComplete = (dotnet-suggest list) | Out-String;
    $availableToCompleteArray = $availableToComplete.Split([Environment]::NewLine, [System.StringSplitOptions]::RemoveEmptyEntries)
    Register-ArgumentCompleter -Native -CommandName $availableToCompleteArray -ScriptBlock {
        param($commandName, $wordToComplete, $cursorPosition)
        $fullpath = (Get-Command $wordToComplete.CommandElements[0]).Source

        $arguments = $wordToComplete.Extent.ToString().Replace('"', '\"')
        dotnet-suggest get -e $fullpath --position $cursorPosition -- "$arguments" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
    $env:DOTNET_SUGGEST_SCRIPT_VERSION = "1.0.0"
}
#endregion
