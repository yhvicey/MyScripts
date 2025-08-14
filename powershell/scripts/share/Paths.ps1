AddToPath ".";
AddToPath "$global:ToolsBinFolder";

if ($env:JAVA_HOME) {
    AddToPath "$env:JAVA_HOME/bin"
}

if ($env:HADOOP_HOME) {
    AddToPath "$env:HADOOP_HOME/bin"
}

if ($env:SPARK_HOME) {
    AddToPath "$env:SPARK_HOME/bin"
}

if (Get-Command python -ErrorAction SilentlyContinue) {
    $scriptsRoot = python -c "import os,sysconfig;print(sysconfig.get_path('scripts',f'{os.name}_user'))"
    AddToPath $scriptsRoot
}

if (Test-Path "$env:PROGRAMFILES\JetBrains") {
    $instances = Get-ChildItem "$env:PROGRAMFILES\JetBrains" -Directory | ForEach-Object {
        @{
            FullName = $_.FullName
            Version  = [version]::Parse(($_.Name -replace "[a-z ]", ""))
        }
    }
    $x86Instances = Get-ChildItem "${env:ProgramFiles(x86)}\JetBrains" -Directory | ForEach-Object {
        @{
            FullName = $_.FullName
            Version  = [version]::Parse(($_.Name -replace "[a-z ]", ""))
        }
    }
    $instances += $x86Instances
    $latestInstance = $instances | Sort-Object Version -Descending | Select-Object -First 1
    AddToPath "$($latestInstance.FullName)\bin"
}