param(
    [Parameter(Mandatory = $true)]
    [string]$PackageName
)

if (Get-Command "nuget" -ErrorAction SilentlyContinue) {
    $globalPackagesRoot = ((nuget locals global-packages -list) -split ": ")[1]

    $packageRoot = "$globalPackagesRoot/$($PackageName.ToLower())"
    if (Test-Path $packageRoot) {
        $packageVersions = Get-ChildItem $packageRoot -Directory | ForEach-Object {
            try {
                [version]::Parse($_.Name)
            }
            catch {
                $null
            }
        }
        $latestVersion = $packageVersions | Sort-Object -Descending | Select-Object -First 1
        return "$packageRoot/$latestVersion"
    }
}
else {
    return $null
}
