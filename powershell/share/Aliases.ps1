function cdd {
    Push-Location $global:Desktop;
}

function cdg {
    Push-Location $global:GithubRepos;
}

function cdmyscripts {
    Push-Location $global:MyScriptsRoot
}

function cdop {
    Push-Location "$env:USERPROFILE/OneDrive/Projects"
}

function cdomp {
    Push-Location "$env:USERPROFILE/OneDrive - Microsoft/Projects"
}

function cdp {
    Push-Location $global:Playground;
}

function cdt {
    Push-Location $global:TempDirs;
}

function cdtool {
    Push-Location $global:ToolsFolder
}

function cdw {
    Push-Location $global:Workspace;
}

function sbin {
    Start-Process $global:ToolsBinFolder
}