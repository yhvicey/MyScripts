param(
    [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

            $results = @()
            # IDEA JDKs
            $ideaJdkRoot = "$env:USERPROFILE\.jdks"
            if (Test-Path $ideaJdkRoot) {
                Get-ChildItem -Path $ideaJdkRoot -Directory | ForEach-Object {
                    $results += "IDEA/$($_.Name)"
                }
            }
            # winget Eclipse Temurin JDKs
            $wingetEclipseJdkRoot = "$env:PROGRAMFILES\Eclipse Adoptium"
            if (Test-Path $wingetEclipseJdkRoot) {
                Get-ChildItem -Path $wingetEclipseJdkRoot -Directory -Filter "jdk-*" | ForEach-Object {
                    $results += "Eclipse/$($_.Name)"
                }
            }
            # winget Microsoft JDKs
            $wingetMicrosoftJdkRoot = "$env:PROGRAMFILES\Microsoft"
            if (Test-Path $wingetMicrosoftJdkRoot) {
                Get-ChildItem -Path $wingetMicrosoftJdkRoot -Directory -Filter "jdk-*" | ForEach-Object {
                    $results += "Microsoft/$($_.Name)"
                }
            }

            foreach ($result in $results) {
                if ($result -like "$wordToComplete*") {
                    [System.Management.Automation.CompletionResult]::new(
                        $result, $result, 'ParameterValue', $result
                    )
                }
            }
        })]
    [string]$Jdk,
    [switch]$Permanent = $False
)

$parts = $Jdk.Split('/', 2)
$source = $parts[0]
$JdkVersion = $parts[1]
switch ($source) {
    "IDEA" {
        $root = "$env:USERPROFILE\.jdks"
        break
    }
    "Eclipse" {
        $root = "$env:PROGRAMFILES\Eclipse Adoptium"
        break
    }
    "Microsoft" {
        $root = "$env:PROGRAMFILES\Microsoft"
        break
    }
    default {
        Write-Error "Unknown JDK source '$source'. Supported sources are: IDEA, Eclipse, Microsoft."
        exit 1
    }
}

$jdkPath = Join-Path $root $JdkVersion
if (-not (Test-Path $jdkPath)) {
    Write-Error "JDK version '$JdkVersion' not found under '$root'"
    exit 1
}

$env:JAVA_HOME = $jdkPath
if ($Permanent) {
    [Environment]::SetEnvironmentVariable("JAVA_HOME", $jdkPath, [EnvironmentVariableTarget]::User)
}
AddToPath "$env:JAVA_HOME\bin" -Prepend

Write-Host "Switched JAVA_HOME to $jdkPath$(if ($Permanent) { ' permanently' })" -ForegroundColor Green
