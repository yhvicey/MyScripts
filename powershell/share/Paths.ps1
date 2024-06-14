AddToPath ".";
AddToPath "C:\Program Files (x86)\GnuWin32\bin";
AddToPath "$global:ToolsBinFolder";
AddToPath "$global:ToolsFolder\python3\Scripts";

$vswhereCmd = Get-Command "vswhere" -ErrorAction SilentlyContinue
if ($vswhereCmd) {
    $installationPath = (& $vswhereCmd.Source | Where-Object { $_ -match "^installationPath: .*" }).Replace("installationPath: ", "")
    # devenv
    $idePath = "$installationPath\Common7\IDE\"
    AddToPath "$idePath"
    # MSBuild
    $msbuildBinPath = "$installationPath\MSBuild\Current\Bin"
    AddToPath "$msbuildBinPath"
}
