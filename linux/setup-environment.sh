#!/usr/bin/env bash

#region Collect input
if [[ -z "$DEV_FOLDER" ]]; then
    read -p "Input development folder path [$HOME/dev]" DEV_FOLDER
fi
if [[ -z "$DEV_FOLDER" ]]; then
    DEV_FOLDER="$HOME/dev"
fi
DEV_FOLDER=${DEV_FOLDER%/}
DEV_FOLDER=${DEV_FOLDER%\\}
if [[ ! -d $DEV_FOLDER ]]; then
    mkdir -p $DEV_FOLDER 1>/dev/null
fi
if [[ -z "$TOOLS_FOLDER" ]]; then
    read -p "Input tools folder path [$HOME/tools]" TOOLS_FOLDER
fi
if [[ -z "$TOOLS_FOLDER" ]]; then
    TOOLS_FOLDER="$HOME/tools"
fi
TOOLS_FOLDER=${TOOLS_FOLDER%/}
TOOLS_FOLDER=${TOOLS_FOLDER%\\}
if [[ ! -d $TOOLS_FOLDER ]]; then
    mkdir -p $TOOLS_FOLDER 1>/dev/null
fi
#endregion

#region Setup shells
SCRIPT_ROOT=$(realpath $(dirname "$0"))
# Install modules
for MODULE in $(cat $SCRIPT_ROOT/modules); do
    echo "Installing or updating $MODULE...";
    sudo apt install -y $MODULE
done
# Setup modules
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
# oh-my-zsh
OH_MY_ZSH_ROOT=~/.oh-my-zsh
[[ -d $OH_MY_ZSH_ROOT ]] && {
    pushd $OH_MY_ZSH_ROOT
    git pull
    popd
} || {
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    chsh -s $(which zsh)
}

# oh-my-posh
OH_MY_POSH_BIN=/usr/local/bin/oh-my-posh
[[ -f $OH_MY_POSH_BIN ]] && rm $OH_MY_POSH_BIN
sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O $OH_MY_POSH_BIN
chmod +x $OH_MY_POSH_BIN

OH_MY_POSH_ROOT=~/.poshthemes
[[ -d $OH_MY_POSH_ROOT ]] && rm -r $OH_MY_POSH_ROOT
mkdir -p $OH_MY_POSH_ROOT
wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O $OH_MY_POSH_ROOT/themes.zip
unzip $OH_MY_POSH_ROOT/themes.zip -d $OH_MY_POSH_ROOT
chmod u+rw $OH_MY_POSH_ROOT/*.json
rm $OH_MY_POSH_ROOT/themes.zip

# fzf
FZF_ROOT=~/.fzf
[[ -d $FZF_ROOT ]] && {
    pushd $FZF_ROOT
    git pull
    popd
} || {
    git clone --depth 1 https://github.com/junegunn/fzf.git $FZF_ROOT
    $FZF_ROOT/install --all
}

# zsh-z
ZSH_Z_ROOT=$ZSH_CUSTOM/plugins/zsh-z
[[ -d $ZSH_Z_ROOT ]] && {
    pushd $ZSH_Z_ROOT
    git pull
    popd
} || {
    git clone --depth 1 https://github.com/agkozak/zsh-z $ZSH_Z_ROOT
    [[ -z "$(grep '^plugins=(.*zsh-z.*)' ~/.zshrc)" ]] && {
        sed -i 's/^plugins=(\(.*\))/plugins=(\1 zsh-z)/g' ~/.zshrc
    }
}
# Setup profiles
TARGET_SHELLS=(
    "bash"
    "zsh"
)
STARTUP_SCRIPT=~/.startup
# Install startup script
STARTUP_SCRIPT_CONTENT=$(<"$SCRIPT_ROOT/startup.sh")
STARTUP_SCRIPT_CONTENT=${STARTUP_SCRIPT_CONTENT//<MY_SCRIPTS_ROOT>/$SCRIPT_ROOT};
STARTUP_SCRIPT_CONTENT=${STARTUP_SCRIPT_CONTENT//<DEV_FOLDER>/$DEV_FOLDER};
STARTUP_SCRIPT_CONTENT=${STARTUP_SCRIPT_CONTENT//<TOOLS_FOLDER>/$TOOLS_FOLDER};
SETUP_FLAG="MY_SCRIPTS_SETUP_DONE"
echo "$STARTUP_SCRIPT_CONTENT" > $STARTUP_SCRIPT
for TARGET_SHELL in ${TARGET_SHELLS[@]}; do
    PROFILE="$HOME/.${TARGET_SHELL}rc"
    if [[ -f $PROFILE ]]; then
        sed -i "/.*$SETUP_FLAG/d" $PROFILE
    else
        touch $PROFILE
    fi
    echo "source $STARTUP_SCRIPT # $SETUP_FLAG" >> $PROFILE
done
#endregion

#region Post setup
echo "Environment setup done."
. $STARTUP_SCRIPT;
# Create other folders
if [[ ! -d $WORKSPACE ]]; then
    mkdir -p $WORKSPACE
fi
if [[ ! -d $PLAYGROUND ]]; then
    mkdir -p $WORKSPACE
fi
if [[ ! -d $GITHUB_REPOS ]]; then
    mkdir -p $WORKSPACE
fi
if [[ ! -d $TEMP_DIRS ]]; then
    mkdir -p $TEMP_DIRS
fi
if [[ ! -d $TOOLS_BIN_FOLDER ]]; then
    mkdir -p $TOOLS_BIN_FOLDER
fi
#endregion