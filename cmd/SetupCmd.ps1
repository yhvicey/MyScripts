$script:ErrorActionPreference = "Stop";

$cmdKeyParentPath = "HKCU:\SOFTWARE\Microsoft"
$cmdKeyName = "Command Processor"
$cmdKeyPath = "$cmdKeyParentPath\$cmdKeyName"
$autorunCommand = "`"$PSScriptRoot\autorun.bat`""
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
elseif (-not ($autorunProp.Autorun -contains $autorunCommand)) {
    Write-Host "Updating Autorun entry";
    Set-ItemProperty -Path $cmdKeyPath -Name "Autorun" -Value "$($autorunProp.Autorun)&$autorunCommand" -Force | Out-Null;
}