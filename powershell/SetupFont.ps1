$Script:ErrorActionPreference = "Stop"

EnsureAdminPrivileges;

function DownloadFromGithubLatestRelease(
    [string] $organization,
    [string] $repo,
    [string] $linkPattern,
    [string] $localFile) {
    $latestReleasePage = Invoke-WebRequest https://github.com/$organization/$repo/releases/latest
    $latestReleaseHref = ($latestReleasePage.Links | Where-Object { $_.href -match "$linkPattern" })[0].href
    if (-not $latestReleaseHref) {
        throw "Latest release link with pattern $linkPattern not found.";
    }
    $latestReleaseDownloadLink = "https://github.com$latestReleaseHref";
    Write-Host "Downloading found release $latestReleaseDownloadLink to $localFile...";
    Invoke-WebRequest $latestReleaseDownloadLink -OutFile $localFile
    Write-Host "Done.";
}

$code = @'
    using System;
    using System.Collections.Generic;
    using System.Text;
    using System.IO;
    using System.Runtime.InteropServices;

    public static class FontUtil {
        [DllImport("gdi32.dll")]
        public static extern int AddFontResource(string lpFilename);
    }
'@
Add-Type $code

function InstallFont(
    [string] $fontFile
) {
    $fontFileName = Split-Path -Leaf $fontFile;
    $fontInstallPath = "C:\Windows\Fonts\$fontFileName";
    if (Test-Path $fontInstallPath) {
        Write-Host "Font $fontFileName already installed.";
        return;
    }
    Copy-Item $fontFile $fontInstallPath;
    Write-Host "Installing $fontFileName...";
    [FontUtil]::AddFontResource($fontInstallPath) | Out-Null
    Write-Host "Done.";
}

# Download Cascadia Code NF, Cascadia Code PL and Cascadia Mono PL
$tempFolder = "$PSScriptRoot/.t";
try {
    if (Test-Path $tempFolder) {
        Remove-Item -Recurse $tempFolder;
    }
    New-Item -ItemType Directory $tempFolder;

    DownloadFromGithubLatestRelease ryanoasis nerd-fonts CascadiaCode.zip "$tempFolder/CascadiaCodeNF.zip"
    DownloadFromGithubLatestRelease microsoft cascadia-code CascadiaCode-.*.zip "$tempFolder/CascadiaCode.zip"
    Expand-Archive "$tempFolder/CascadiaCodeNF.zip" "$tempFolder/CascadiaCodeNF";
    Expand-Archive "$tempFolder/CascadiaCode.zip" "$tempFolder/CascadiaCode";
    Get-ChildItem "$tempFolder/CascadiaCodeNF" -Recurse -Filter "*.ttf" | Where-Object {
        $_.Name.Contains("Windows")
    } | ForEach-Object {
        InstallFont $_.FullName;
    }
    Get-ChildItem "$tempFolder/CascadiaCode/ttf" -Recurse -Filter "*.ttf" | ForEach-Object {
        InstallFont $_.FullName;
    }
}
finally {
    if (Test-Path $tempFolder) {
        Remove-Item -Recurse $tempFolder;
    }
}
