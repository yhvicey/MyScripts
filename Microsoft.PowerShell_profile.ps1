#region Global variables
# Folders
$global:MyScriptsRoot = "<MyScriptsRoot>";
$global:DevFolder = "<DevFolder>";
$global:Workspace = "$DevFolder/Workspace";
$global:Playground = "$DevFolder/Playground";
$global:GithubRepos = "$DevFolder/Github";
$global:SharedData = "$DevFolder/SharedData";
$global:ToolsFolder = "<ToolsFolder>";
$global:Desktop = "$([Environment]::GetFolderPath("desktop"))";
$global:TempDirs = "$Desktop/tempDirs";
#endregion

#region Load scripts & modules
function LoadScripts([string] $folder) {
    foreach ($scriptPath in (Get-ChildItem -Recurse $folder -Filter "*.ps1")) {
        try {
            . $scriptPath.FullName;
        }
        catch {
            Write-Warning "Failed to load $($scriptPath.FullName), error: $_";
        }
    }
}
LoadScripts "$MyScriptsRoot/powershell/share";
LoadScripts "$MyScriptsRoot/powershell/$([System.Environment]::OSVersion.Platform.ToString().ToLower())";
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
# Modules
Set-Theme Agnoster;
#endregion
