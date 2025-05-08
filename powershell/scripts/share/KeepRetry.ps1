param(
    [scriptblock]$CodeBlock,
    [int]$RetryInterval = 1
)

do {
    & $CodeBlock
    $succeeded = $LASTEXITCODE -eq 0
    if (-not $succeeded) {
        Write-Host "Retrying in $RetryInterval seconds..."
        Start-Sleep -Seconds $RetryInterval
    }
} while (-not $succeeded)
