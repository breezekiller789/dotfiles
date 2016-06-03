#!/usr/bin/env bash

usage() {
    echo "Usage: $0 [-n] [vim|restore]" >&2
    echo "  -n: do NOT update submodules"
    exit 0
}

case "$OSTYPE" in
    darwin*)
        OS=Darwin
        ;;
    linux*)
        issue=`cat /etc/issue`
        cat /etc/issue | grep Ubuntu && OS=Ubuntu
        ;;
    *)
        ;;
esac

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

has() {
    hash $1 >/dev/null 2>&1
}

function install_prerequisites {
    if [ "$OS" = "Darwin" ]; then
        if ! `which brew`; then
            echo '*** Error: I need homebrew to install dependencies'
            echo '*** If you continue, some functions may not work properly'
            read -p '> Continue anyway? (yes or no)'
            [[ $ans =~ [Yy].* ]] || exit 1
        fi
        has ctags || brew install ctags
        has ag || brew install the_silver_searcher
    elif [ "$OS" = "Ubuntu" ]; then
        sudo apt-get update
        sudo apt-get install -yq --force-yes ctags silversearcher-ag
    else
        echo "*** Please install ctags, silversearcher by hand"
    fi

    # eslint for syntastic
    if ! has npm ; then
        echo 'If you need jsxhint, please install npm and run:'
        echo '  npm install -g eslint babel-eslint eslint-plugin-react'
    elif ! has jsxhint ; then
        echo 'If you develop jsx, then eslint is needed by syntastic'
        read -p "Do you need eslint? (yes or no) "
        npm install -g eslint babel-eslint eslint-plugin-react
    fi
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

submodules=`git submodule | awk '{print $2}'`
for x in _vim/bundle/*; do
    echo "$submodules" | grep $x >/dev/null 2>&1 || rm -rf $x
done
git submodule update --init --recursive

if [ -z $no_update ]; then
    git submodule foreach --recursive git pull origin master
fi

# Prerequisites of YouCompleteMe
# - cmake
# - build-essential
