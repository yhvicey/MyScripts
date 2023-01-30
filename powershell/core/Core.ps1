function AppendToPath([string] $folder) {
    $normalizedFolderPath = [System.IO.Path]::GetFullPath($folder);
    if (-not ($env:PATH.Contains($normalizedFolderPath))) {
        Write-Debug "Adding $normalizedFolderPath to PATH";
        $env:PATH = "$($env:PATH)$([System.IO.Path]::PathSeparator)$normalizedFolderPath";
    }
}

function EncodeToBase64(
    [Parameter(ValueFromPipeline = $true)]
    [string]$Raw
) {
    Begin {}
    Process {
        return [System.Convert]::ToBase64String([System.Text.ENcoding]::UTF8.GetBytes($Raw))
    }
    End {}
}

function EnsureAdminPrivileges {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        throw "Insufficient permissions to run this script. Open the PowerShell console as an administrator and run this script again.";
    }
}

function EnsureDirectoryExists(
    [string]$File
) {
    if ([System.IO.File]::Exists($File)) {
        throw "Target $File is a directory."
    }
    if (-not [System.IO.Directory]::Exists($File)) {
        throw "Target directory $File not exists."
    }
}

function EnsureFileExists(
    [string]$File
) {
    if ([System.IO.Directory]::Exists($File)) {
        throw "Target $File is a directory."
    }
    if (-not [System.IO.File]::Exists($File)) {
        throw "Target file $File not exists."
    }
}

function EnsureNotNullOrEmpty(
    [Parameter(ValueFromPipeline = $true)]
    [string]$Value
) {
    Begin {}
    Process {
        if ([string]::IsNullOrEmpty($Value)) {
            throw "Value is null or empty"
        }
    }
    End {}
}

function EnsureOS([string] $os) {
    $currentOs = [System.Environment]::OSVersion.Platform.ToString();
    if ($currentOs.ToLower() -ne $os.ToLower()) {
        throw "OS not matched. Requires $os but got $currentOs";
    }
}

function DecodeFromBase64(
    [Parameter(ValueFromPipeline = $true)]
    [string]$Encoded
) {
    Begin {}
    Process {
        return [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Encoded))
    }
    End {}
}

function PrependToPath([string] $folder) {
    $normalizedFolderPath = [System.IO.Path]::GetFullPath($folder);
    if (-not ($env:PATH.Contains($normalizedFolderPath))) {
        Write-Debug "Prepending $normalizedFolderPath to PATH";
        $env:PATH = "$normalizedFolderPath$([System.IO.Path]::PathSeparator)$($env:PATH)";
    }
}

function ReloadProfile {
    . $PROFILE
}

function StartProcessOrPath {
    if ($args.Count -eq 0) {
        Start-Process -FilePath .;
    }
    else {
        Start-Process -FilePath $args[0] $args;
    }
}
Set-Alias "s" "StartProcessOrPath";