function ClearGitBranches(
    [string]$Remote = "origin"
) {
    $function:ErrorActionPreference = "Stop";
    $gitExe = (Get-Command "git").Path;
    & $gitExe fetch;
    & $gitExe remote prune $Remote;
    $branches = @();
    & $gitExe branch -v | Where-Object { $_ -match "gone" } | Foreach-Object {
        if ($_ -match "  ([\w/-]+)") {
            $branches += $Matches[1];
        }
    }

    if ($branches.Length -eq 0) {
        Write-Host "No obsolete branch.";
        return;
    }

    Write-Host "Below branches will be deleted:"
    $branches | ForEach-Object {
        Write-Host "  $_";
    }

    if (!((Read-Host -Prompt "Confirm? [y/n]") -match "(y|Y)")) {
        return;
    }

    $branches | ForEach-Object {
        Write-Host "Deleting branch $_...";
        & $gitExe branch -D $_;
    }

    Write-Host "Done.";
}
Set-Alias "cgb" "ClearGitBranches";