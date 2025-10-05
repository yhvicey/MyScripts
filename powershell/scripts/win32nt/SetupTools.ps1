param(
    [switch]$SkipWinget = $false,
    [switch]$SkipChocolatey = $false
)

& "$PSScriptRoot/../../SetupTools.ps1" -SkipWinget:$SkipWinget -SkipChocolatey:$SkipChocolatey
