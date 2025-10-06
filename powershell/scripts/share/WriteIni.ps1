param(
    [Parameter(Mandatory)]
    [hashtable]$IniData,
    [Parameter(Mandatory)]
    [string]$IniFilePath
)

$iniLines = @()
foreach ($section in $IniData.Keys) {
    $iniLines += "[$section]"
    foreach ($key in $IniData[$section].Keys) {
        $value = $IniData[$section][$key]
        $iniLines += "$key=$value"
    }
    $iniLines += ""  # Add a blank line after each section
}

Set-Content -Path $IniFilePath -Value $iniLines