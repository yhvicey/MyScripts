param(
    [ValidateSet("all", "snipaste", "hadoop")]
    [Parameter(Mandatory)]
    [string]$Tool
)

$toolsBackupRoot = "$HOME/OneDrive/Backup/Tools"

if ($Tool -in ("all", "snipaste")) {
    try {
        Write-Host "Installing snipaste..."

        $snipasteZip = "$toolsBackupRoot/Snipaste-1.16.2-x86.zip"
        Expand-Archive $snipasteZip "$ToolsFolder/Snipaste"
        Start-Process "$ToolsFolder/Snipaste/Snipaste.exe"

        Write-Host "Done."
    }
    catch {
        Write-Host "Failed to install snipaste: $_"
    }
}

if ($Tool -in ("all", "hadoop")) {
    try {
        Write-Host "Installing hadoop..."

        & choco upgrade --install-if-not-installed --ignore-dependencies hadoop
        $hadoopVersion = GetChocolateyPackageVersion "hadoop"
        GithubClone https://github.com/cdarlint/winutils

        Write-Host "Copying hadoop winutils..."

        $winUtilsSourceFolder = "$GithubRepos/cdarlint/winutils/hadoop-$hadoopVersion"
        $localHadoopRoot = "C:/Hadoop"
        $hadoopHome = "$localHadoopRoot/hadoop-$hadoopVersion"
        Copy-Item "$winUtilsSourceFolder/bin/*" "$hadoopHome/bin" -Force
        [Environment]::SetEnvironmentVariable("HADOOP_HOME", $hadoopHome, [EnvironmentVariableTarget]::Machine)

        Write-Host "Done."
    }
    catch {
        Write-Host "Failed to install hadoop: $_"
    }
}