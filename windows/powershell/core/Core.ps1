function AppendToPath([string] $folder) {
    $normalizedFolderPath = [System.IO.Path]::GetFullPath($folder);
    if (-not ($env:PATH.Contains($normalizedFolderPath))) {
        Write-Debug "Adding $normalizedFolderPath to PATH";
        $env:PATH = "$($env:PATH)$([System.IO.Path]::PathSeparator)$normalizedFolderPath";
    }
}

function EnsureAdminPrivileges {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        throw "Insufficient permissions to run this script. Open the PowerShell console as an administrator and run this script again.";
    }
}

function EnsureOS([string] $os) {
    $currentOs = [System.Environment]::OSVersion.Platform.ToString();
    if ($currentOs.ToLower() -ne $os.ToLower()) {
        throw "OS not matched. Requires $os but got $currentOs";
    }
}

function PrependToPath([string] $folder) {
    $normalizedFolderPath = [System.IO.Path]::GetFullPath($folder);
    if (-not ($env:PATH.Contains($normalizedFolderPath))) {
        Write-Debug "Prepending $normalizedFolderPath to PATH";
        $env:PATH = "$normalizedFolderPath$([System.IO.Path]::PathSeparator)$($env:PATH)";
    }
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