function AddToPath([string] $folder) {
    $normalizedFolderPath = [System.IO.Path]::GetFullPath($folder);
    if (-not ($env:PATH.Contains($normalizedFolderPath))) {
        $env:PATH = "$($env:PATH)$([System.IO.Path]::PathSeparator)$normalizedFolderPath";
    }
}

function EnsureAdminPrivileges {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error "Insufficient permissions to run this script. Open the PowerShell console as an administrator and run this script again."
        exit;
    }
}

function GetDiskUsage([string]$Directory = ".") {
    Get-ChildItem $Directory | ForEach-Object {
        $folder = $_;
        Get-ChildItem -r $_.FullName | Measure-Object -Property Length -Sum | Select-Object @{
            Name       = "Name";
            Expression = {
                $folder
            }
        }, @{
            Name       = "Length";
            Expression = {
                Get-FileSize $_.Sum;
            }
        }, Sum
    } | Sort-Object -Property Sum -Descending | Select-Object Name, Length
}
Set-Alias "sdu" "GetDiskUsage";

function GetFileSize([long]$fileSize) {
    switch ($fileSize) {
        { $_ -gt 1tb } {
            return "{0:n2} TB" -f ($_ / 1tb);
        }
        { $_ -gt 1gb } {
            return "{0:n2} GB" -f ($_ / 1gb);
        }
        { $_ -gt 1mb } {
            return "{0:n2} MB" -f ($_ / 1mb);
        }
        { $_ -gt 1kb } {
            return "{0:n2} KB" -f ($_ / 1kb);
        }
        Default {
            return "{0:n2} B" -f $_;
        }
    }
}
Set-Alias "fsize" "GetFileSize";

function StartProcessOrPath {
    if ($args.Count -eq 0) {
        Start-Process -FilePath .;
    }
    else {
        Start-Process -FilePath $args[0] $args;
    }
}
Set-Alias "s" "StartProcessOrPath";