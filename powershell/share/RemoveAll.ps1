function RemoveAll(
    [string]$Path
) {
    Remove-Item $Path -Recurse -Force
}
Set-Alias "rmrf" "RemoveAll";