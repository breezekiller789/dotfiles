#!/usr/bin/env bash

usage() {
    echo "Usage: $0 [-n] [vim|restore]" >&2
    echo "  -n: do NOT update submodules"
    exit 0
}

if [ -n `which apt-get 2>/dev/null` ]; then
    INSTALL="sudo apt-get install"
elif [ -n `which brew 2>/dev/null` ]; then
    INSTALL="brew install"
fi

function link_file {
    source="${PWD}/$1"
    target="${HOME}/${1/_/.}"

    if [ -e "${target}" ] && [ ! -L "${target}" ]; then
        mv $target $target.df.bak
    fi

    ln -sf ${source} ${target}
}

function unlink_file {
    source="${PWD}/$1"
    target="${HOME}/${1/_/.}"

    if [ -e "${target}.df.bak" ] && [ -L "${target}" ]; then
        unlink ${target}
        mv $target.df.bak $target
    elif [ -L "${target}" ]; then
        unlink ${target}
    fi
}

function install_if_needed {
    if [ -z `which $1` ]; then
        echo "Installing $1 ... (might need your password)"
        $INSTALL $1
    fi
}

function install_prerequisites {
    install_if_needed ctags
}

if [ "$1" = "vim" ]; then
    for i in _vim*
    do
       link_file $i
    done
elif [ "$1" = "restore" ]; then
    for i in _*
    do
        unlink_file $i
    done
    exit
else
    install_prerequisites
    for i in _*
    do
        link_file $i
    done
fi

while getopts n option; do
    case $option in
        n)
            echo "Skipping submodule updates..."
            no_update=1
            ;;
        *)
            usage
            ;;
    esac
done

if [ -z $no_update ]; then
    git submodule update --init --recursive
    git submodule foreach --recursive git pull origin master
fi
