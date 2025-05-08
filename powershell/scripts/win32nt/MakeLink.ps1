param(
    [Parameter(Mandatory)]
    [string]$Link,
    [Parameter(Mandatory)]
    [string]$Target,
    [switch]$HardLink = $false,
    [switch]$Force = $false
)

EnsureNotNullOrEmpty $Link
EnsureNotNullOrEmpty $Target

$targetAbsPath = Resolve-Path $Target
if ([System.IO.Directory]::Exists($targetAbsPath)) {
    $opts = "/D"
}
if ((Test-Path $Link) -and $Force) {
    Remove-Item $Link
}
if ($HardLink) {
    $opts = "$opts /H"
}
cmd /c "mklink $opts `"$Link`" `"$targetAbsPath`""
