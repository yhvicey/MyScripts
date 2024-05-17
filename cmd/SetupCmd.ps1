$script:ErrorActionPreference = "Stop";

$cmdKeyParentPath = "HKCU:\SOFTWARE\Microsoft"
$cmdKeyName = "Command Processor"
$cmdKeyPath = "$cmdKeyParentPath\$cmdKeyName"
$autorunScript = "autorun.bat"
$autorunCommand = "`"$PSScriptRoot\$autorunScript`""
# Create parent key
if (-not (Test-Path $cmdKeyPath)) {
    Write-Host "Creating cmd key";
    New-Item -Path $cmdKeyParentPath -Name $cmdKeyName -Force | Out-Null;
}
# Autorun
$autorunProp = Get-ItemProperty -Path $cmdKeyPath -Name "Autorun" -ErrorAction SilentlyContinue;
if (-not $autorunProp) {
    Write-Host "Creating Autorun entry";
    New-ItemProperty -Path $cmdKeyPath -Name "Autorun" -Value $autorunCommand -Force | Out-Null;
}
else {
    $entries = @($autorunProp.Autorun.Split("&"))
    $updatedEntries = @()
    $scriptInstalled = $false
    foreach ($entry in $entries) {
        if (-not $scriptInstalled -and $entry.Contains($autorunScript)) {
            $entry = $autorunCommand
            $scriptInstalled = $true
        }
        $updatedEntries += $entry
    }
    if (-not $scriptInstalled) {
        $updatedEntries += $autorunCommand
    }
    $autorunPropValue = [string]::Join("&", $updatedEntries)
    Write-Host "Updating Autorun entry, was $($autorunProp.Autorun), new value $autorunPropValue";
    Set-ItemProperty -Path $cmdKeyPath -Name "Autorun" -Value "$autorunPropValue" -Force | Out-Null;
}