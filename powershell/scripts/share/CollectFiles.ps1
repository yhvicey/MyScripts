param(
    [Parameter(Mandatory)]
    [string]$Filter,
    [string]$Path = "."
)

return Get-ChildItem -Recurse -File -Filter:$Filter -Path:$Path