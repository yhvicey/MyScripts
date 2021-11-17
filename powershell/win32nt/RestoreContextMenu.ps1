function RestoreContextMenu(
    [switch]$Revert = $false
) {
    $regKey = "HKCU:\Software\Classes\CLSID\{86CA1AA0-34AA-4E8B-A509-50C905BAE2A2}";
    if ($Revert) {
        if (Test-Path $regKey) {
            Remove-Item $regKey -Recurse -Force;
        }
        Write-Host "Done.";
    }
    else {
        $subRegKey = "$regKey\InprocServer32\";
        if (-not (Test-Path $regKey)) {
            Write-Host "$regKey not found, creating...";
            [void](New-Item -Path $regKey);
        }
        if (-not (Test-Path $subRegKey)) {
            Write-Host "$subRegKey not found, creating...";
            [void](New-Item -Path $subRegKey);
        }
        Set-ItemProperty $subRegKey -Name "(Default)" -Value ""
        Write-Host "Done.";
    }
}
