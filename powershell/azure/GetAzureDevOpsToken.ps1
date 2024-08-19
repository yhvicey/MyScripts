function GetAzureDevOpsToken() {
    $script:ErrorActionPreference = "Stop"
    $token = az account get-access-token `
        --scope "499b84ac-1321-427f-aa17-267ca6975798/.default" `
        --query accessToken `
        -o tsv
    $token = $token.ToString()
    $token | Set-Clipboard
    Write-Output $token
}