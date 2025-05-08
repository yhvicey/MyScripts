param(
    [switch]$Revert = $false
)

$regKey = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem";
if ($Revert) {
    if (Test-Path $regKey) {
        Set-ItemProperty $subRegKey -Name "LongPathsEnabled" -Value 0
    }
    Write-Host "Done.";
}
else {
    if (-not (Test-Path $regKey)) {
        Write-Host "$regKey not found, creating...";
        [void](New-Item -Path $regKey);
    }
    Set-ItemProperty $regKey -Name "LongPathsEnabled" -Value 1
    Write-Host "Done.";
}
