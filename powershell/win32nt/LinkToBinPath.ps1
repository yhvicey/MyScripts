function LinkToBinPath(
    [Parameter(Mandatory)]
    [string]$Target
) {
    EnsureFileExists $Target
    $binName = Split-Path $Target -Leaf
    MakeLink "$global:ToolsBinFolder/$binName" $Target -Force
}
Set-Alias "ln2bin" "LinkToBinPath";