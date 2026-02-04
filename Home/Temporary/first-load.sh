#!/bin/sh
username=$(whoami)

# Enable sound services
systemctl --user enable wireplumber.service pipewire.service pipewire-pulse.service

# Places folder creation
ln -s /home/$username/.config /home/$username/System/Places/Config
ln -s /home/$username/.local/share /home/$username/System/Places/Share
if [ -x /usr/bin/ssh ]; then
    ln -s /home/$username/.ssh/ /home/$username/System/SSH
fi
if [ -x /usr/bin/steam ]; then
    mkdir -p /home/$username/.local/share/Steam/
    ln -s /home/$username/.local/share/Steam/ /home/$username/System/Places/Steam
fi

# Create public folder
mkdir -p /home/$username/Public
ln -s /public /home/$username/Public/

# Remove from .bashrc
sed -i '\#$HOME/Temporary/first-load.sh#d' "$HOME/.bashrc" # Removing from .bashrc if exist

# Remove temporary folder
rm -rf /home/$username/Temporary