#!/bin/sh

cd $(realpath `dirname $0`)
source pacman-tools/check_status.sh

check_sudo

echo -e "Install pacman-tools\n"

if [ $(pacman -Qi curl git pacman-contrib sed >&/dev/null; echo $?) != 0 ]; then
    check_internet
    
    echo "Install packages required"
    sudo pacman -S --needed --noconfirm curl git pacman-contrib sed 2>/dev/null
fi

echo "Add the scripts in /etc/pacman.d/pacman-tools/"
sudo cp -r ./pacman-tools /etc/pacman.d/
sudo chmod -R +x /etc/pacman.d/pacman-tools/

echo "Add aliases for bash"
sudo cp ./pacman_tools.bashrc /etc/bash/bashrc.d/

echo -e "\nSuccess to install pacman-tools"
exit 0