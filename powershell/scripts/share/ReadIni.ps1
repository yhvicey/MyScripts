param(
    [Parameter(Mandatory)]
    [string]$IniFilePath
)

if (-not (Test-Path $IniFilePath)) {
    throw "INI file not found: $IniFilePath"
}

$iniContent = Get-Content $IniFilePath
$iniHashTable = @{}
$currentSection = ""
foreach ($line in $iniContent) {
    $trimmedLine = $line.Trim()
    if ($trimmedLine -match '^\s*;') {
        continue
    }
    if ($trimmedLine -match '^\s*\[(.+?)\]\s*$') {
        $currentSection = $matches[1]
        if (-not $iniHashTable.ContainsKey($currentSection)) {
            $iniHashTable[$currentSection] = @{}
        }
    }
    elseif ($trimmedLine -match '^\s*([^=]+?)\s*=\s*(.*?)\s*$' -and $currentSection) {
        $key = $matches[1].Trim()
        $value = $matches[2].Trim()
        $iniHashTable[$currentSection][$key] = $value
    }
}

return $iniHashTable