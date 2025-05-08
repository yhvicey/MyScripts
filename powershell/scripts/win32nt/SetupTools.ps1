param(
    [switch]$SkipChocolatey = $false,
    [switch]$SkipWinget = $false
)

& "$PSScriptRoot/../SetupTools.ps1" -SkipChocolatey:$SkipChocolatey -SkipWinget:$SkipWinget
