function GoToDesktop {
    Set-Location $global:Desktop;
}
Set-Alias "cdd" "GoToDesktop"

function GoToGithubRepos {
    Set-Location $global:GithubRepos;
}
Set-Alias "cdg" "GoToGithubRepos"

function GoToMyScriptsRoot {
    Set-Location $global:MyScriptsRoot
}
Set-Alias "cdmyscripts" "GoToMyScriptsRoot"

function GoToOneDriveMicrosoftProjects {
    Set-Location "$env:USERPROFILE/OneDrive - Microsoft/Projects"
}
Set-Alias "cdodmp" "GoToOneDriveMicrosoftProjects"

function GoToOneDriveProjects {
    Set-Location "$env:USERPROFILE/OneDrive/Projects"
}
Set-Alias "cdodp" "GoToOneDriveProjects"

function GoToParent {
    Set-Location "..";
}
Set-Alias ".." "GoToParent"

function GoToPlayground {
    Set-Location $global:Playground;
}
Set-Alias "cdp" "GoToPlayground"

function GoToTempDirs {
    Set-Location $global:TempDirs;
}
Set-Alias "cdt" "GoToTempDirs"

function GoToToolsFolder {
    Set-Location $global:ToolsFolder
}
Set-Alias "cdtool" "GoToToolsFolder"

function GoToWorkspace {
    Set-Location $global:Workspace;
}
Set-Alias "cdw" "GoToWorkspace"

function PushLocationToDesktop {
    Set-Location $global:Desktop;
}
Set-Alias "pd" "PushLocationToDesktop"

function PushLocationToGithubRepos {
    Set-Location $global:GithubRepos;
}
Set-Alias "pg" "PushLocationToGithubRepos"

function PushLocationToMyScriptsRoot {
    Set-Location $global:MyScriptsRoot
}
Set-Alias "pmyscripts" "PushLocationToMyScriptsRoot"

function PushLocationToOneDriveMicrosoftProjects {
    Set-Location "$env:USERPROFILE/OneDrive - Microsoft/Projects"
}
Set-Alias "podmp" "PushLocationToOneDriveMicrosoftProjects"

function PushLocationToOneDriveProjects {
    Set-Location "$env:USERPROFILE/OneDrive/Projects"
}
Set-Alias "podp" "PushLocationToOneDriveProjects"

function PushLocationToParent {
    Set-Location "..";
}
Set-Alias "p.." "PushLocationToParent"

function PushLocationToPlayground {
    Set-Location $global:Playground;
}
Set-Alias "pp" "PushLocationToPlayground"

function PushLocationToTempDirs {
    Set-Location $global:TempDirs;
}
Set-Alias "pt" "PushLocationToTempDirs"

function PushLocationToToolsFolder {
    Set-Location $global:ToolsFolder
}
Set-Alias "ptool" "PushLocationToToolsFolder"

function PushLocationToWorkspace {
    Set-Location $global:Workspace;
}
Set-Alias "pw" "PushLocationToWorkspace"
