AddToPath ".";
AddToPath "$global:ToolsBinFolder";

if ($env:JAVA_HOME) {
    AddToPath "$env:JAVA_HOME/bin" -Prepend -Force
}

if ($env:HADOOP_HOME) {
    AddToPath "$env:HADOOP_HOME/bin"
}

if ($env:SPARK_HOME) {
    AddToPath "$env:SPARK_HOME/bin"
}

if (Get-Command python -ErrorAction SilentlyContinue) {
    try {
        $scriptsRoot = python -c "import os,sysconfig;print(sysconfig.get_path('scripts',f'{os.name}_user'))"
        AddToPath $scriptsRoot
    }
    catch {}
}

if (Test-Path "$env:PROGRAMFILES\JetBrains") {
    [array]$instances = Get-ChildItem "$env:PROGRAMFILES\JetBrains" -Directory | ForEach-Object {
        [PSCustomObject]@{
            FullName = $_.FullName
            Version  = [version]::Parse(($_.Name -replace "[a-z ]", ""))
        }
    }
    if (Test-Path "${env:ProgramFiles(x86)}\JetBrains") {
        [array]$x86Instances = Get-ChildItem "${env:ProgramFiles(x86)}\JetBrains" -Directory | ForEach-Object {
            [PSCustomObject]@{
                FullName = $_.FullName
                Version  = [version]::Parse(($_.Name -replace "[a-z ]", ""))
            }
        }
    }
    else {
        $x86Instances = @()
    }
    $instances += $x86Instances
    $global:instances = $instances
    if ($instances.Count -ne 0) {
        $latestInstance = ([array]$instances) | Sort-Object Version -Descending | Select-Object -First 1
        AddToPath "$($latestInstance.FullName)\bin"
    }
}

if (Test-Path "C:\msys64") {
    AddToPath "C:\msys64\usr\bin"
}