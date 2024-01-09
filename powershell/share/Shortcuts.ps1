function GoToDesktop {
    Push-Location $global:Desktop;
}
Set-Alias "cdd" "GoToDesktop"

function GoToGithubRepos {
    Push-Location $global:GithubRepos;
}
Set-Alias "cdg" "GoToGithubRepos"

function GoToMyScriptsRoot {
    Push-Location $global:MyScriptsRoot
}
Set-Alias "cdmyscripts" "GoToMyScriptsRoot"

function GoToOneDriveMicrosoftProjects {
    Push-Location "$env:USERPROFILE/OneDrive - Microsoft/Projects"
}
Set-Alias "cdomp" "GoToOneDriveMicrosoftProjects"

function GoToOneDriveProjects {
    Push-Location "$env:USERPROFILE/OneDrive/Projects"
}
Set-Alias "cdop" "GoToOneDriveProjects"

function GoToParent {
    Push-Location "..";
}
Set-Alias ".." "GoToParent"

function GoToPlayground {
    Push-Location $global:Playground;
}
Set-Alias "cdp" "GoToPlayground"

function GoToTempDirs {
    Push-Location $global:TempDirs;
}
Set-Alias "cdt" "GoToTempDirs"

function GoToToolsFolder {
    Push-Location $global:ToolsFolder
}
Set-Alias "cdtool" "GoToToolsFolder"

function GoToWorkspace {
    Push-Location $global:Workspace;
}
Set-Alias "cdw" "GoToWorkspace"
