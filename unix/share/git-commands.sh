alias gfom="git fetch origin master:master"
alias gpom="git pull origin master"

function gcb {
    git checkout branch $1 "$@";
}

function gcnb {
    git checkout branch -b $1 "$@";
}