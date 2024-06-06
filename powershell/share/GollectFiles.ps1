function CollectFiles(
    [Parameter(Mandatory)]
    [string]$Filter
) {
    return Get-ChildItem -Recurse -File -Filter:$Filter
}
Set-Alias "cf" "CollectFiles";