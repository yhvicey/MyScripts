function AddToPath([string] $Folder, [System.EnvironmentVariableTarget] $Target = [EnvironmentVariableTarget]::Process, [switch]$Prepend = $false) {
    if ($Folder -eq ".") {
        $normalizedFolderPath = $Folder
    }
    else {
        $normalizedFolderPath = [System.IO.Path]::GetFullPath($Folder);
    }
    Write-Verbose "Normalized path: $normalizedFolderPath"
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", $Target)
    Write-Verbose "Current PATH: $currentPath"

    if (-not [System.Collections.Generic.HashSet[string]]::new($currentPath.Split([System.Environment]::PathSeparator)).Contains($normalizedFolderPath)) {
        if ($Target -ne [System.EnvironmentVariableTarget]::Process) {
            Write-Debug "Adding $normalizedFolderPath to PATH, target $Target, prepend $Prepend";
        }
        if ($Prepend) {
            $updatedPath = "$normalizedFolderPath$([System.IO.Path]::PathSeparator)$currentPath";
        }
        else {
            $updatedPath = "$currentPath$([System.IO.Path]::PathSeparator)$normalizedFolderPath";
        }
        [Environment]::SetEnvironmentVariable("PATH", $updatedPath, $Target)
    }
    else {
        Write-Debug "Path $normalizedFolderPath already exists in PATH"
    }
}

function Confirm([string]$Message = "", [bool]$DefaultResult = $false, [switch]$NewLine = $false) {
    $Message = $Message.Trim()
    if (-not [string]::IsNullOrEmpty($Message)) {
        if ($NewLine) {
            $Message = "$Message`n"
        }
        else {
            $Message = "$Message "
        }
    }
    if ($DefaultResult) {
        $prompt = "$($Message)Confirm? [Y/n]"
    }
    else {
        $prompt = "$($Message)Confirm? [y/N]"
    }
    $userChoice = Read-Host -Prompt $prompt
    if ($userChoice -match "(y|Y)") {
        return $true
    }
    if ([string]::IsNullOrEmpty($userChoice)) {
        return $DefaultResult
    }
    return $false
}

function EchoAndInvoke([string]$Expression, [switch]$Confirm = $false) {
    $message = "Running: $Expression"
    if ($Confirm) {
        if (-not (Confirm $message -NewLine)) {
            return
        }
    }
    else {
        Write-Host $message
    }
    Invoke-Expression $Expression
}

function EncodeToBase64(
    [Parameter(ValueFromPipeline = $true)]
    [string]$Raw
) {
    Begin {}
    Process {
        return [System.Convert]::ToBase64String([System.Text.ENcoding]::UTF8.GetBytes($Raw))
    }
    End {}
}

function EnsureAdminPrivileges {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        throw "Insufficient permissions to run this script. Open the PowerShell console as an administrator and run this script again.";
    }
}

function EnsureDirectoryExists(
    [string]$File
) {
    if ([System.IO.File]::Exists($File)) {
        throw "Target $File is a directory."
    }
    if (-not [System.IO.Directory]::Exists($File)) {
        throw "Target directory $File not exists."
    }
}

function EnsureFileExists(
    [string]$File
) {
    if ([System.IO.Directory]::Exists($File)) {
        throw "Target $File is a directory."
    }
    if (-not [System.IO.File]::Exists($File)) {
        throw "Target file $File not exists."
    }
}

function EnsureNotNullOrEmpty(
    [Parameter(ValueFromPipeline = $true)]
    [string]$Value
) {
    Begin {}
    Process {
        if ([string]::IsNullOrEmpty($Value)) {
            throw "Value is null or empty"
        }
    }
    End {}
}

function EnsureOS([string] $os) {
    $currentOs = [System.Environment]::OSVersion.Platform.ToString();
    if ($currentOs.ToLower() -ne $os.ToLower()) {
        throw "OS not matched. Requires $os but got $currentOs";
    }
}

function DecodeFromBase64(
    [Parameter(ValueFromPipeline = $true)]
    [string]$Encoded
) {
    Begin {}
    Process {
        return [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Encoded))
    }
    End {}
}

function ReadHostWithOptions {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Prompt,
        [Parameter(Mandatory = $true)]
        [string[]]$Choices,
        [switch]$AllowManualInput,
        $ManualInputLabel = "Type my own"
    )

    $x = 0;
    $Menu = @()
    $manualInputLabel = "<" + $manualInputLabel + ">"
    foreach ($item in $Choices) {
        $x += 1
        $row = New-Object PSObject -Property @{
            Option = $item;
            Index  = $x
        }
        $Menu += $row
    }
    if ($AllowManualInput) {
        $row = New-Object PSObject -Property @{
            Option = $manualInputLabel;
            Index  = ($x + 1)
        }
        $Menu += $row
    }
    $Menu | ForEach-Object {
        Write-Host "$($_.Index): $($_.Option)"
    }
    do {
        $select = Read-Host -Prompt $Prompt
        $allowedIndexes = $Menu | Select-Object -ExpandProperty Index
    } until ($allowedIndexes -contains $select)
    return $Menu | Where-Object { $_.Index -eq $select } | Select-Object -ExpandProperty Option
}