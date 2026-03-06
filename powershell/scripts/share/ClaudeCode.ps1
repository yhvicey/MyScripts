param(
    [string]$Session = $null
)

$ccArgs = @(
    "--dangerously-skip-permissions"
)

if (-not [string]::IsNullOrEmpty($Session)) {
    $ccArgs += "--resume"
    $ccArgs += $Session
}

& claude $ccArgs