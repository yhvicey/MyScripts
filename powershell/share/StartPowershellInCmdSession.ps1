function StartPowershellInCmdSession(
    [Parameter(Mandatory)]
    [string]$CmdScript
) {
    $scriptPath = (Resolve-Path $CmdScript).Path
    Start-Process "cmd /k $scriptPath && powershell"
}
Set-Alias "spic" "StartPowershellInCmdSession";