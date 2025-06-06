function gfom {
    git fetch origin master:master $args;
}

function gpom {
    git pull origin master $args;
}

function gcb(
    [Parameter(Mandatory)]
    [string] $name) {
    git checkout branch $name $args;
}

function gcnb(
    [Parameter(Mandatory)]
    [string] $name) {
    git checkout branch -b $name $args;
}

function gwip() {
    $message = "WIP: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $branchName = "$(git rev-parse --abbrev-ref HEAD)-wip"
    git checkout -b $branchName
    git add *
    git commit -am $message
    git push origin $branchName
}