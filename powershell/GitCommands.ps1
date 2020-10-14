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