function GoToGitRepoRoot() {
    $currentPath = (Get-Location).Path
    do {
        $parentDir = Split-Path -Parent $currentPath
        if ([string]::IsNullOrEmpty($parentDir)) {
            return
        }
        if (Test-Path (Join-Path $parentDir ".git")) {
            Push-Location $parentDir
            return
        }
        $currentPath = $parentDir
    } while ($true)
}
Set-Alias "reporoot" "GoToGitRepoRoot"