param(
    [Parameter(Mandatory)]
    [string]$Directory,
    [Parameter(Mandatory)]
    [scriptblock]$Command
)

$script:ErrorActionPreference = "Stop"

$directoryPath = Resolve-Path -Path $Directory
try {
    Push-Location -Path $directoryPath
    & $Command
}
finally {
    Pop-Location
}