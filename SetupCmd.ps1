EnsureAdminPrivileges;
$script:ErrorActionPreference = "Stop";

# HKLM:\SOFTWARE\Microsoft\Command Processor
if (-not (Test-Path "HKLM:\SOFTWARE\Microsoft\Command Processor")) {
    Write-Host "Creating cmd key";
    New-Item -Path "HKLM:\SOFTWARE\Microsoft" -Name "Command Processor" -Force | Out-Null;
}
# Autorun
$autorunValue = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Command Processor" -Name "Autorun" -ErrorAction SilentlyContinue;
if (-not $autorunValue) {
    Write-Host "Creating Autorun entry";
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Command Processor" -Name "Autorun" -Value "$global:MyScriptsRoot\cmd\autorun.bat" -Force | Out-Null;
} else {
    Write-Host "Updating Autorun entry";
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Command Processor" -Name "Autorun" -Value "$global:MyScriptsRoot\cmd\autorun.bat" -Force | Out-Null;
}