function GithubClone(
    [string]$RepoOrOrg,
    [string]$Repo = $null,
    [switch]$OpenInCode = $false
) {
    if ($RepoOrOrg.Contains("/")) {
        $Org = $RepoOrOrg.Split("/")[0]
        $Repo = $RepoOrOrg.Split("/")[1]
    }
    else {
        $Org = $RepoOrOrg
        if ($null -eq $Repo) {
            throw "Repo must be specified"
        }
    }
    try {
        Push-Location $global:GithubRepos
        $repoUri = [System.Uri]::new("https://github.com/$Org/$Repo")
        $localFolder = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($global:GithubRepos, [string]::Join("", $repoUri.Segments).Trim("/")))
        git clone $Repo $localFolder
        if ($OpenInCode) {
            code $localFolder
        }
    }
    finally {
        Pop-Location
    }
}
Set-Alias "ghclone" "GithubClone";