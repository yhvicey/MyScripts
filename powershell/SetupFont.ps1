$Script:ErrorActionPreference = "Stop"
$currentProgressPreference = $ProgressPreference
$ProgressPreference = "SilentlyContinue"

EnsureAdminPrivileges;

function DownloadFromGithubLatestRelease(
    [string] $organization,
    [string] $repo,
    [string] $namePattern,
    [string] $localFile) {
    $latestReleases = Invoke-WebRequest "https://api.github.com/repos/$organization/$repo/releases/latest" -UseBasicParsing | ConvertFrom-Json
    $latestReleaseDownloadLink = ($latestReleases.assets | Where-Object { $_.name -match "$namePattern" })[0].browser_download_url
    if (-not $latestReleaseDownloadLink) {
        throw "Latest release link with pattern $namePattern not found.";
    }
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
        [DllImport("user32.dll")]
        public static extern int SendMessage(int hWnd, uint Msg, int wParam, int lParam);
        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern int WriteProfileString(string lpszSection, string lpszKeyName, string lpszString);
    }
'@
Add-Type $code

$WM_FONTCHANGE = 0x001D;
$HWND_BROADCAST = 0xffff;

function InstallFont(
    [string] $fontFile
) {
    $fontFileName = Split-Path -Leaf $fontFile;
    $fontName = [System.IO.Path]::GetFileNameWithoutExtension($fontFile)
    $fontInstallPath = "C:\Windows\Fonts\$fontFileName";
    if (Test-Path $fontInstallPath) {
        Write-Host "Font $fontFileName already installed.";
        return;
    }
    Copy-Item $fontFile $fontInstallPath;
    Write-Host "Installing $fontFileName...";
    [FontUtil]::AddFontResource($fontInstallPath) | Out-Null;
    [FontUtil]::WriteProfileString("fonts", $fontName, $fontFileName) | Out-Null;
    [FontUtil]::SendMessage($HWND_BROADCAST, $WM_FONTCHANGE, 0, 0) | Out-Null;
    Write-Host "Done.";
}

# Download Cascadia Code NF, Cascadia Code PL and Cascadia Mono PL
$tempFolder = "$PSScriptRoot/.t";
try {
    if (Test-Path $tempFolder) {
        Remove-Item -Recurse $tempFolder;
    }
    [void](New-Item -ItemType Directory $tempFolder);

    DownloadFromGithubLatestRelease ryanoasis nerd-fonts CascadiaCode.zip "$tempFolder/CascadiaCodeNF.zip"
    DownloadFromGithubLatestRelease microsoft cascadia-code CascadiaCode-.*.zip "$tempFolder/CascadiaCode.zip"
    Expand-Archive "$tempFolder/CascadiaCodeNF.zip" "$tempFolder/CascadiaCodeNF";
    Expand-Archive "$tempFolder/CascadiaCode.zip" "$tempFolder/CascadiaCode";
    Get-ChildItem "$tempFolder/CascadiaCodeNF" -Recurse -Filter "*.otf" | Where-Object {
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
    $ProgressPreference = $currentProgressPreference
}
