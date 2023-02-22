function GithubClone(
    [string]$Repo,
    [switch]$OpenInCode = $false
) {
    try {
        Push-Location $global:GithubRepos
        $repoUri = [System.Uri]::new($Repo)
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