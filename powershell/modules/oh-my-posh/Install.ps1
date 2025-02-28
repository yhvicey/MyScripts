$currentOS = [System.Environment]::OSVersion.Platform.ToString().ToLower()
switch ($currentOS) {
    { $_ -eq "win32nt" } {
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
    }
    { $_ -eq "unix" } {
        curl -s https://ohmyposh.dev/install.sh | bash -s
    }
    Default {
        Write-Warning "Unsupported OS $currentOS, skipping oh-my-posh installation"
    }
}
