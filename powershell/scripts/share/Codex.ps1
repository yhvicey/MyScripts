param(
    [string]$Session = $null
)

$cxArgs = @()

if (-not [string]::IsNullOrEmpty($Session)) {
    $ccArgs += "resume"
    $ccArgs += $Session
}

$cxArgs += "--dangerously-bypass-approvals-and-sandbox"

& codex $cxArgs