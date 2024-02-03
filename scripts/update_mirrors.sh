#!/bin/sh

cd `realpath $(dirname $0)` || exit 1
. ./check_status.sh

usage() {
    printf "Usage : update-mirrors [OPTIONS] [MIRRORS]\n\n"
    echo "Commands :"
    echo "  -h, --help    : Display this help."
    echo ""
    echo "Options :"
    echo "  -b, --backup  : Create a backup of the old mirrorlist file."
    echo "  -r, --refresh : Refresh the master package database."
    echo "  -v, --verbose : Verbose mode."
    echo ""
    echo "Mirrors :"
    echo "  -a, --all     : Update all Linux mirrors."
    echo "      --arch    : Update Arch Linux mirrors."
    echo "      --artix   : Update Artix Linux mirrors."
    echo ""
}

update_mirror_list() {
    check_internet
    check_sudo

    file=/etc/pacman.d/mirrorlist$([[ $(cat /etc/os-release | sed -e "/$1/b" -e d) ]] && echo '' || echo -$1)
    [ ! "$BACKUP" ] || sudo cp $file $file.backup

    if [ "$VERBOSE" ]; then
        curl -s $2 | sed 's/#Server/Server/' | rankmirrors -w -n 6 - | sudo tee $file && sudo sed -i '/^#/d' $file
        [ ! "$REFRESH" ] || sudo pacman -Syy

        printf "\nSuccess to update $1 mirrors\n"
    else
        curl -s $2 | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -w -n 6 - | sudo tee $file;
        [ ! "$REFRESH" ] || sudo pacman -Syy >/dev/null 2>&1
    fi
}

if [ "$#" = 0 ]; then
    usage
    exit 0
fi
while [ "$#" != 0 ]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -b|--backup)
            BACKUP=true
            b=-b
            shift
            ;;
        -r|--refresh)
            REFRESH=true
            r=-r
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            v=-v
            shift
            ;;
        -a|--all)
            ./update_mirrors.sh $b $r $v --arch --artix
            exit 0
            ;;
        --arch)
            update_mirror_list "arch" "https://archlinux.org/mirrorlist/?country=all&protocol=https&use_mirror_status=on"
            shift
            ;;
        --artix)
            update_mirror_list "artix" "https://gitea.artixlinux.org/packages/artix-mirrorlist/raw/branch/master/mirrorlist"
            shift
            ;;
        *)
            echo "Error: Unknown option '$1'"
            usage
            exit 1
            ;;
    esac
done

exit 0