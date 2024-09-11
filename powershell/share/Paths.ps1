AddToPath ".";
AddToPath "C:\Program Files (x86)\GnuWin32\bin";
AddToPath "$global:ToolsBinFolder";
AddToPath "$global:ToolsFolder\python3\Scripts";

$vswhereCmd = Get-Command "vswhere" -ErrorAction SilentlyContinue
if ($vswhereCmd) {
    $installationPath = & $vswhereCmd.Source -all | Where-Object { $_ -match "^installationPath: .*" }
    if (-not $installationPath) {
        Write-Debug "VS installation path not found"
        return
    }
    $installationPath = $installationPath.Replace("installationPath: ", "")
    # devenv
    $idePath = "$installationPath\Common7\IDE\"
    AddToPath "$idePath"
    # MSBuild
    $msbuildBinPath = "$installationPath\MSBuild\Current\Bin"
    AddToPath "$msbuildBinPath"
}

if ($env:JAVA_HOME) {
    AddToPath "$env:JAVA_HOME/bin"
}

if ($env:HADOOP_HOME) {
    AddToPath "$env:HADOOP_HOME/bin"
}

if ($env:SPARK_HOME) {
    AddToPath "$env:SPARK_HOME/bin"
}