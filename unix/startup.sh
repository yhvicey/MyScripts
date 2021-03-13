#region Global variables
# Folders
export MY_SCRIPTS_ROOT="<MY_SCRIPTS_ROOT>";
export DEV_FOLDER="<DEV_FOLDER>";
export WORKSPACE="$DEV_FOLDER/Workspace";
export PLAYGROUND="$DEV_FOLDER/Playground";
export GITHUB_REPOS="$DEV_FOLDER/Github";
export TOOLS_FOLDER="<TOOLS_FOLDER>";
export TEMP_DIRS="$HOME/tempDirs";

# Colors
export CYAN='\033[36m'
export YELLOW='\033[33m'
export RESET='\033[0m'

# Others
export CURRENT_SHELL=$(echo $SHELL | sed "s/.*\/\(.*\)$/\1/g")
#endregion

#region Load scripts & modules
FOLDERS_TO_LOAD_SCRIPTS_FROM=(
    "$MY_SCRIPTS_ROOT/share"
    "$MY_SCRIPTS_ROOT/$(echo $CURRENT_SHELL | awk '{print tolower($0)}')"
);
for folder in $FOLDERS_TO_LOAD_SCRIPTS_FROM; do
    [[ -d $folder ]] && for scriptPath in $(find $folder -type f -name "*.sh"); do
        {
            [[ ! -z "$MYSCRIPT_DEBUG" ]] && echo "Loading $scriptPath"
            source $scriptPath
        } || {
            echo -e "${YELLOW}Failed to load $scriptPath.$RESET"
        }
    done
done
#endregion

#region Settings
# Tools
if which dotnet-suggest 1>/dev/null; then
    # dotnet-suggest
    _dotnet_bash_complete()
    {
        local fullpath=`type -p ${COMP_WORDS[0]}`
        local escaped_comp_line=$(echo "$COMP_LINE" | sed s/\"/'\\\"'/g)
        local completions=`dotnet-suggest get --executable "${fullpath}" --position ${COMP_POINT} -- "${escaped_comp_line}"`

        if [ "${#COMP_WORDS[@]}" != "2" ]; then
            return
        fi

        local IFS=$'\n'
        local suggestions=($(compgen -W "$completions"))

        if [ "${#suggestions[@]}" == "1" ]; then
            local number="${suggestions[0]/%\ */}"
            COMPREPLY=("$number")
        else
            for i in "${!suggestions[@]}"; do
                suggestions[$i]="$(printf '%*s' "-$COLUMNS"  "${suggestions[$i]}")"
            done

            COMPREPLY=("${suggestions[@]}")
        fi
    }

    _dotnet_bash_register_complete()
    {
        local IFS=$'\n'
        complete -F _dotnet_bash_complete `dotnet-suggest list`
    }
    _dotnet_bash_register_complete
    export DOTNET_SUGGEST_SCRIPT_VERSION="1.0.1"
fi
# Modules
eval "$(oh-my-posh --init --shell $CURRENT_SHELL --config ~/.poshthemes/agnoster.omp.json)"
#endregion