param(
    [Parameter(Mandatory)]
    [string]$CmdScript,
    [scriptblock]$PostStartupScripts = {}
)

& "cmd" "/k $CmdScript && powershell -NoLogo -Command { $PostStartupScripts }"
