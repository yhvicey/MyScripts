param(
    [Parameter(Mandatory = $true)]
    [System.IO.FileInfo]$Path
)

Add-Type -AssemblyName Microsoft.VisualBasic

[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($Path.FullName, 'OnlyErrorDialogs', 'SendToRecycleBin')