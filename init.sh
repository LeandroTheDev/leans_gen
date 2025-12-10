#!/bin/sh

# Sequential script for initialize the leans gen installation from internet

pacman -Sy git
git clone https://github.com/LeandroTheDev/leans_gen
cd ./leans_gen
chmod +x -R ./
leansgen.sh