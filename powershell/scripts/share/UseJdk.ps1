param(
    [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

            $root = if ($env:JDK_ROOT) {
                $env:JDK_ROOT
            }
            else {
                "$env:USERPROFILE\.jdks"
            }

            if (Test-Path $root) {
                Get-ChildItem -Path $root -Directory | ForEach-Object {
                    if ($_.Name -like "$wordToComplete*") {
                        [System.Management.Automation.CompletionResult]::new(
                            $_.Name, $_.Name, 'ParameterValue', $_.FullName
                        )
                    }
                }
            }
        })]
    [string]$JdkVersion
)

$root = if ($env:JDK_ROOT) {
    $env:JDK_ROOT
}
else {
    "$env:USERPROFILE\.jdks"
}
$jdkPath = Join-Path $root $JdkVersion

if (-not (Test-Path $jdkPath)) {
    Write-Error "JDK version '$JdkVersion' not found under '$root'"
    exit 1
}

$env:JAVA_HOME = $jdkPath
AddToPath "$env:JAVA_HOME\bin" -Prepend

Write-Host "Switched JAVA_HOME to $jdkPath" -ForegroundColor Green
