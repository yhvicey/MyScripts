function GithubClone(
    [string]$RepoOrOrgOrUrl,
    [string]$Repo = $null,
    [switch]$OpenInCode = $false
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
    try {
        Push-Location $global:GithubRepos
        $repoUri = [System.Uri]::new("https://github.com/$Org/$Repo")
        $localFolder = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($global:GithubRepos, [string]::Join("", $repoUri.Segments).Trim("/")))
        git clone $repoUri $localFolder
        if ($OpenInCode) {
            code $localFolder
        }
    }
    finally {
        Pop-Location
    }
}
Set-Alias "ghclone" "GithubClone";