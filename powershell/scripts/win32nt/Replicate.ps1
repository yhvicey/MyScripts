param(
    [string]$Source,
    [string]$Destination
)

if (!(Test-Path -Path $Source -PathType Container)) {
    throw "Source path is not a directory."
}

if (!(Test-Path -Path $Destination -PathType Container)) {
    throw "Destination path is not a directory."
}

robocopy $Source.TrimEnd("\") $Destination.TrimEnd("\") /Z /E /MT
