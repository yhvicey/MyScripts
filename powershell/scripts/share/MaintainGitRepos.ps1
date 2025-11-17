param(
    [Parameter(Mandatory = $true)]
    [string]$RepoListPath,
    [string]$WorkingDirectory = (Get-Location).Path,
    [switch]$IgnoreUncommittedChanges = $false
)

$repoList = Import-Csv -Path $RepoListPath

foreach ($repo in $repoList) {
    $localFolder = Join-Path -Path $WorkingDirectory -ChildPath $repo.LocalFolder
    switch ($repo.Type) {
        "AzureDevOps" {
            $repoUrl = "https://$($repo.Org)@dev.azure.com/$($repo.Org)/$($repo.Project)/_git/$($repo.Repository)"
        }
        "Github" {
            $repoUrl = "https://github.com/$($repo.Org)/$($repo.Repository).git"
        }
        default {
            Write-Warning "Unsupported repository type '$($repo.Type)' for repository '$($repo.Repository)'. Skipping."
            continue
        }
    }
    $repoUrl = [uri]::EscapeUriString($repoUrl)

    if (Test-Path -Path $localFolder -ErrorAction SilentlyContinue) {
        try {
            Push-Location -Path $localFolder
            $currentBranch = git rev-parse --abbrev-ref HEAD
            if ($currentBranch -ne $repo.Branch) {
                Write-Warning "Current branch '$currentBranch' does not match expected branch '$($repo.Branch)' in local repository '$($repo.LocalFolder)'. Skipping update."
            }
            else {
                $workingDocCount = git status --porcelain | Measure-Object -Line
                if (-not $IgnoreUncommittedChanges -and $workingDocCount.Lines -gt 0) {
                    Write-Warning "There are uncommitted changes in local repository '$($repo.LocalFolder)'. Please commit or stash them before updating. Skipping update."
                }
                else {
                    Write-Host "Updating local repository '$($repo.LocalFolder)' on branch '$($repo.Branch)'..."
                    git pull origin $repo.Branch
                }
            }
        }
        finally {
            Pop-Location
        }
    }
    else {
        Write-Host "Cloning repository '$($repo.Repository)' into folder '$localFolder'..."
        git clone -b $repo.Branch $repoUrl $localFolder
    }
}