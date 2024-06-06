function CollectFiles(
    [Parameter(Mandatory)]
    [string]$Filter,
    [string]$Path = "."
) {
    return Get-ChildItem -Recurse -File -Filter:$Filter -Path:$Path
}
Set-Alias "cf" "CollectFiles";