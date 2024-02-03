#!/bin/sh

usage() {
    printf "Usage : pactools [TOOL]\n\n"
    echo "Commands :"
    echo "  -h, --help           : Display this help."
    echo "      --update         : Update pactools."
    echo "      --uninstall      : Uninstall pactools."
    echo ""
    echo "Tools :"
    echo "  -c, --clean          : Clean pacman cache and remove unused dependencies."
    echo "  -f, --fix-keys       : Refresh pacman keys."
    echo "  -u, --update-mirrors : Update pacman mirrors."
    echo ""
}

check_internet() {
    if ! ping -c 1 -q github.com >/dev/null 2>&1; then
        echo "Error: No Internet connection"
        exit 1
    fi
}
check_sudo() {
    if ! sudo -v; then
        echo "Root privileges denied";
        exit 1
    fi
}

clean_pacman() {
    check_sudo

    sudo pacman -Scc
    pacman -Qdt >/dev/null && sudo pacman -Rsn `pacman -Qdtq`
}

fix_keys() {
    check_internet
    check_sudo

    sudo rm -rf /etc/pacman.d/gnupg /var/lib/pacman/sync
    sudo pacman -Syy
    sudo pacman-key --init
    for keyring in `pacman -Qq | sed -e "/keyring/b" -e d | sort -r`; do
        sudo pacman-key --populate `echo $keyring | sed "s/-keyring//g"`
        sudo pacman -S --noconfirm $keyring
        printf "\nSuccess to fix $keyring\n"
    done
}

update_mirrors() {
    check_internet
    check_sudo

    /etc/pacman.d/update_mirrors.sh
}

update() {
    check_internet
    check_sudo

    printf "Update pactools\n\n"
    
    sudo git clone https://github.com/Angel-Karasu/pactools.git /var/tmp/pactools
    sudo chmod +x /var/tmp/pactools/install.sh
    sudo sed -i 's|Add|Update|g; s|printf|#printf|g'  /var/tmp/pactools/install.sh
    echo ""
    /var/tmp/pactools/install.sh

    printf "\nSuccess to update pactools\n"
}

uninstall() {
    sudo rm -f /etc/pacman.d/update_mirrors.sh /usr/local/bin/pactools
    echo "Success to uninstall pactools"
}

if [ "$#" = 0 ]; then
    usage
else
    case "$1" in
        -h|--help)
            usage;;
        --update)
            update;;
        --uninstall)
            uninstall;;
        -c|--clean)
            clean_pacman;;
        -f|--fix-keys)
            fix_keys;;
        -u|--update-mirrors)
            update_mirrors;;
        *)
            echo "Error: Unknown option '$1'"
            usage
            exit 1
            ;;
    esac
    exit 0
fi