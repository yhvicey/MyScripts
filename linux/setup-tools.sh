#!/bin/bash

set -e # Exit at any error

ensure-admin-privileges

[[ -d $TOOLS_FOLDER ]] || (
    echo "Tools folder not defined, run setup-environment.sh first."
    exit 1;
)

# Setup sources
# nodejs
curl -fsSL https://deb.nodesource.com/setup_15.x | sudo -E bash -
# python
add-apt-repository ppa:deadsnakes/ppa
apt-get update

# Install tools
for TOOL in $(cat $SCRIPT_ROOT/tools); do
    echo "Installing or updating $TOOL...";
    sudo apt install -y $TOOL
done

#region Post setup
echo "Tools setup done."
#endregion