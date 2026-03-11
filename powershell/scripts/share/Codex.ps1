param(
    [string]$Session = $null
)

$cxArgs = @()

if (-not [string]::IsNullOrEmpty($Session)) {
    $cxArgs += "resume"
    $cxArgs += $Session
}

$cxArgs += "--dangerously-bypass-approvals-and-sandbox"

& codex $cxArgs