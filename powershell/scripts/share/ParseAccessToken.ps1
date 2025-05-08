param(
    [string]$AccessToken
)

$base64Url = $AccessToken.Split('.')[1]
$base64 = $base64Url.Replace('-', '+').Replace('_', '/')
if ($base64.Length % 4 -ne 0) {
    $base64 += '=' * (4 - ($base64.Length % 4))
}
$jsonBytes = [System.Convert]::FromBase64String($base64)
$jsonString = [System.Text.Encoding]::UTF8.GetString($jsonBytes)
return ConvertFrom-Json -InputObject $jsonString