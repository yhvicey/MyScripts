param(
    [switch]$Revert = $false
)

$regKey = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem";
if ($Revert) {
    if (Test-Path $regKey) {
        Set-ItemProperty $subRegKey -Name "LongPathsEnabled" -Value 0
    }

    if (Get-Command -Name "git" -ErrorAction SilentlyContinue) {
        git config --global core.longpaths false
    }

    Write-Host "Done.";
}
else {
    if (-not (Test-Path $regKey)) {
        Write-Host "$regKey not found, creating...";
        [void](New-Item -Path $regKey);
    }
    Set-ItemProperty $regKey -Name "LongPathsEnabled" -Value 1

    if (Get-Command -Name "git" -ErrorAction SilentlyContinue) {
        git config --global core.longpaths true
    }

    Write-Host "Done.";
}
