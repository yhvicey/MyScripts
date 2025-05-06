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