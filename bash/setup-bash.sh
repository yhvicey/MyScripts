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

#region Setup bash
SCRIPT_ROOT=$(realpath $(dirname "$0"))
PROFILE=~/.bashrc
STARTUP_SCRIPT=~/.startup
# Install startup script
STARTUP_SCRIPT_CONTENT=$(<"$SCRIPT_ROOT/startup.sh")
STARTUP_SCRIPT_CONTENT=${STARTUP_SCRIPT_CONTENT//<MY_SCRIPTS_ROOT>/$SCRIPT_ROOT};
STARTUP_SCRIPT_CONTENT=${STARTUP_SCRIPT_CONTENT//<DEV_FOLDER>/$DEV_FOLDER};
STARTUP_SCRIPT_CONTENT=${STARTUP_SCRIPT_CONTENT//<TOOLS_FOLDER>/$TOOLS_FOLDER};
SETUP_FLAG="MY_SCRIPTS_SETUP_DONE"
echo "$STARTUP_SCRIPT_CONTENT" > $STARTUP_SCRIPT
# Setup profile
if [[ -f $PROFILE ]]; then
    sed -i "/.*$SETUP_FLAG/d" $PROFILE
else
    touch $PROFILE
fi
echo "source $STARTUP_SCRIPT # $SETUP_FLAG" >> $PROFILE
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
#endregion