param(
    [scriptblock]$CodeBlock,
    [int]$RetryInterval = 1
)

do {
    if ($CodeBlock -eq $null) {
        $command = Get-History -Count 1 | Select-Object -ExpandProperty CommandLine
        $CodeBlock = [scriptblock]::Create($command)
    }
    & $CodeBlock
    $succeeded = $LASTEXITCODE -eq 0
    if (-not $succeeded) {
        Write-Host "Retrying in $RetryInterval seconds..."
        Start-Sleep -Seconds $RetryInterval
    }
} while (-not $succeeded)
