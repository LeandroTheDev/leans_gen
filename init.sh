#!/bin/sh

# Sequential script for initialize the leans gen installation from internet

timedatectl set-ntp true
pacman -Sy archlinux-keyring --noconfirm

pacman -Sy git
git clone https://github.com/LeandroTheDev/leans_gen
cd ./leans_gen
./leansgen.sh