param(
    [string]$PackageName
)

$Script:ErrorActionPreference = "Stop"

$output = & choco list --exact $PackageName --limit-output
if ($LASTEXITCODE -ne 0) {
    return $null
} else {
    $parts = $output -split '\|'
    if ($parts.Length -eq 2) {
        return $parts[1]
    } else {
        return $null
    }
}