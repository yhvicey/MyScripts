param(
    [string]$Session = $null
)

$cxArgs = @(
    "--dangerously-bypass-approvals-and-sandbox"
)

if (-not [string]::IsNullOrEmpty($Session)) {
    $ccArgs += "resume"
    $ccArgs += $Session
}

& codex $cxArgs