function StartPowershellInCmdSession(
    [Parameter(Mandatory)]
    [string]$CmdScript
) {
    $scriptPath = (Resolve-Path $CmdScript).Path
    & "cmd" "/k $scriptPath && powershell -NoLogo"
}
Set-Alias "spic" "StartPowershellInCmdSession";