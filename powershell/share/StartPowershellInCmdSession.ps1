function StartPowershellInCmdSession(
    [Parameter(Mandatory)]
    [string]$CmdScript
) {
    & "cmd" "/k $CmdScript && powershell -NoLogo"
}
Set-Alias "spic" "StartPowershellInCmdSession";