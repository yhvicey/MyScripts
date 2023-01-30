[console]::InputEncoding = [console]::OutputEncoding = [System.Text.Encoding]::UTF8; # Change code page
Set-PSReadlineKeyHandler -Key Tab -Function Complete # Set bash-style completion
Set-PSReadlineOption -BellStyle None # No bell