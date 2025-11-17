param(
    [scriptblock]$CodeBlock,
    [int]$MaxRetries = -1,
    [int]$RetryInterval = 1,
    [switch]$SilentlyContinue = $false
)

$retryTime = 0
do {
    if ($CodeBlock -eq $null) {
        $command = Get-History -Count 1 | Select-Object -ExpandProperty CommandLine
        $CodeBlock = [scriptblock]::Create($command)
    }
    & $CodeBlock
    $succeeded = $LASTEXITCODE -eq 0
    if (-not $succeeded) {
        $retryTime++
        if ($MaxRetries -ge 0 -and $retryTime -gt $MaxRetries) {
            if (-not $SilentlyContinue) {
                Write-Error "Operation failed after $MaxRetries retries."
            }
            break
        }
        Write-Host "Retrying in $RetryInterval seconds..."
        Start-Sleep -Seconds $RetryInterval
    }
} while (-not $succeeded)
