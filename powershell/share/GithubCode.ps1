function GithubCode(
    [string]$RepoOrOrgOrUrl,
    [string]$Repo = $null,
    [switch]$CloneIfNotExists = $false
) {
    if ($RepoOrOrgOrUrl -match "https://github.com/([^/]+)/([^/]+)") {
        $Org = $Matches[1]
        $Repo = $Matches[2]
    }
    elseif ($RepoOrOrgOrUrl.Contains("/")) {
        $Org = $RepoOrOrgOrUrl.Split("/")[0]
        $Repo = $RepoOrOrgOrUrl.Split("/")[1]
    }
    else {
        $Org = $RepoOrOrgOrUrl
        if ($null -eq $Repo) {
            throw "Repo must be specified"
        }
    }
    $codeExe = (Get-Command "code" -ErrorAction SilentlyContinue).Path
    if (($null -eq $codeExe) -or -not (Test-Path $codeExe)) {
        throw "VS code not found in path"
    }

    $localFolder = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($global:GithubRepos, $Org, $Repo)) -replace ".git$"
    if ($-not (Test-Path $localFolder)) {
        if ($CloneIfNotExists -or (Confirm "Repo not exists, clone to local?" -DefaultResult $true)) {
            GithubClone -RepoOrOrgOrUrl:$RepoOrOrgOrUrl -Repo:$Repo
        }
        else {
            return
        }
    }
    & $codeExe $localFolder
}
Set-Alias "ghcode" "GithubCode";