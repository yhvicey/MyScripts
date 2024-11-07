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