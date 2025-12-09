#!/bin/sh

# Check if git is installed
if command -v git >/dev/null 2>&1; then
    echo "Git is already installed: $(git --version)"
else
    echo "Git not found. Installing..."
    pacman -Sy --noconfirm git

    if command -v git >/dev/null 2>&1; then
        echo "Git successfully installed: $(git --version)"
    else
        echo "Failed to install git."
        exit 1
    fi
fi
