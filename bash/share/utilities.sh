function ensure-admin-privileges {
    if [[ $(id -u) -ne 0 ]]; then
        echo "Insufficient permissions to run this script. Rerun as root user."
        return
    fi
}

function start-process-or-path {
    if [[ $# -eq 0 ]]; then
        PATH_TO_START=$(/bin/wslpath -w $PWD)
    else
        PATH_TO_START=$(/bin/wslpath -w $1)
    fi

    cmd.exe /c start "" "$PATH_TO_START" 1>/dev/null 2>/dev/null
}
alias s=start-process-or-path