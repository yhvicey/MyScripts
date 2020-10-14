$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1";
if (Test-Path $chocolateyProfile) {
    Import-Module $chocolateyProfile; # Chocolatey
}