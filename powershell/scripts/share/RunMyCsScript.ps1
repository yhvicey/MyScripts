param(
    [string]$ScriptFile
)

$scriptPath = [System.IO.Path]::Combine($global:MyScriptsRoot, "csharp", $ScriptFile.Replace(".cs", "") + ".cs")
& dotnet run $scriptPath -- @args