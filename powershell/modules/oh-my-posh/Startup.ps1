switch ($global:CurrentOS) {
    { $_ -eq "Unix" } {
        AddToPath "$env:HOME/.local/bin"
    }
}
oh-my-posh init pwsh --config "$PSScriptRoot/config.json" | Invoke-Expression