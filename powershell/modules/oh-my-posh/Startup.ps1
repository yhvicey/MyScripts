switch ($global:CurrentOS) {
    { $_ -eq "Unix" } {
        AddToPath "$env:HOME/.local/bin"
    }
    { $_ -eq "Win32NT" } {
        AddToPath "$env:LOCALAPPDATA\Programs\oh-my-posh\bin"
    }
}
oh-my-posh init pwsh --config "$PSScriptRoot/config.json" | Invoke-Expression