function ReloadProfile {
    if (Get-Command refreshenv -ErrorAction "SilentlyContinue") {
        refreshenv
    }
    . $PROFILE
}
Set-Alias "rel" "ReloadProfile"