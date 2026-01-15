param(
    [switch]$SkipWinget = $false,
    [switch]$SkipChocolatey = $false,
    [switch]$EditWingetList = $false,
    [switch]$EditChocolateyList = $false
)

& "$PSScriptRoot/../../SetupTools.ps1" -SkipWinget:$SkipWinget -SkipChocolatey:$SkipChocolatey -EditWingetList:$EditWingetList -EditChocolateyList:$EditChocolateyList