function GetK8sDashboardToken(
    [ValidateSet(
        "adstool"
    )]
    [string]$ServiceAccount = "adstool",
    [string]$Duration = "24h"
) {
    EnsureNotNullOrEmpty $ServiceAccount
    $token = kubectl create token $ServiceAccount -n kube-system --duration $Duration
    $token | Set-Clipboard
    Write-Host "Token for $ServiceAccount have been copied to clipboard."
}
