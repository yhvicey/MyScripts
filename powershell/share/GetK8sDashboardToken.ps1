function GetK8sDashboardToken(
    [ValidateSet(
        "adstool"
    )]
    [string]$ServiceAccount = "adstool"
) {
    EnsureNotNullOrEmpty $ServiceAccount
    $token = kubectl create token $ServiceAccount -n kube-system
    $token | Set-Clipboard
    Write-Host "Token for $ServiceAccount have been copied to clipboard."
}
