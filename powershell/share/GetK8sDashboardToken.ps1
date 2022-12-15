function GetK8sDashboardToken(
    [ValidateSet(
        "web3datadri-token"
    )]
    [string]$TokenNamePattern = "web3datadri-token"
) {
    EnsureNotNullOrEmpty $TokenNamePattern
    $tokenName = ((kubectl get secret -n kube-system | Where-Object { $_ -match $TokenNamePattern }) -split " ")[0]
    $token = kubectl get secret -n kube-system "$tokenName" -o jsonpath='{.data.token}'
    $token | DecodeFromBase64 | Set-Clipboard
    Write-Host "Token for $TokenNamePattern have been copied to clipboard."
}
