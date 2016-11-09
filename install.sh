#!/usr/bin/env bash

usage() {
    cat <<EOF
Usage: $0 [OPTIONS] [vim|restore]

Options:
    -h|--help: show this usage
    --with-ycm: install with YCM support
    --update: update submodules to latest versions
    --with-jsxhint: install with jsxhint support
EOF
    exit 0
}

red='\033[91m'
green='\033[92m'
blue='\033[94m'
yellow='\033[93m'
white='\033[0m'

say() {
    if [ "$(ps -p $$ -ocomm=)" = "bash" ]; then
        echo -e "$1"
    else
        echo "$1"
    fi
}

info() {
    say "${blue}[+]${white} $1"
}

warn() {
    say "${yellow}[+]${white} $1"
}

error() {
    say "${red}[-]${white} $1"
}

get_unified_os_name() {
    case "$OSTYPE" in
        darwin*)
            echo Darwin
            ;;
        linux*)
            issue=`cat /etc/issue`
            if cat /etc/issue | grep Ubuntu >/dev/null 2>&1; then
                echo Ubuntu
            fi
            ;;
        *)
            echo Unknown
            return 1
            ;;
    esac
    return 0
}

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
            error 'I need homebrew to install dependencies'
            error 'If you continue, some functions may not work properly'
            while true; do
                read -p '> Continue anyway? (yes or no) ' ans
                case $ans in
                    [yY]*)
                        info 'Continuing'
                        break
                        ;;
                    [nN]*)
                        info 'Aborting...'
                        exit 1
                        ;;
                    *)
                        error "Invalid answer: $ans"
                        ;;
                esac
            done
        fi
        has ctags || brew install ctags
        has ag || brew install the_silver_searcher
    elif [ "$OS" = "Ubuntu" ]; then
        sudo apt-get update
        sudo apt-get install -yq --force-yes ctags silversearcher-ag
    else
        warn 'Please install ctags, silversearcher by hand'
    fi

    if [ $opt_with_ycm -eq 1 ]; then
        install_ycm || error "Failed to install YCM"
    fi

    if [ $opt_with_jsxhint -eq 1 ]; then
        install_jsxhint
    fi

}

install_jsxhint() {
    if ! has npm ; then
        if [ "$OS" = "Darwin" ]; then
            brew install npm
        elif [ "$OS" = "Ubuntu" ]; then
            sudo apt-get install npm
        fi
    fi

    if ! has jsxhint ; then
        npm install -g eslint babel-eslint eslint-plugin-react
    fi
}

install_ycm() {
    pushd _vim/bundle/YouCompleteMe
    info "Installing dependencies for YCM..."
    for x in cmake clang; do
        if ! has $x; then
            if [ "$OS" = "Darwin" ]; then
                brew install $x
            elif [ "$OS" = "Ubuntu" ]; then
                apt-get install -yq --force-yes $x
            else
                error "Missing dependency: $x (Please install by hand)"
                return 1
            fi
        fi
    done
    ./install.py --clang-completer
    popd
}

main() {
    OS=`get_unified_os_name`

    opt_with_ycm=0
    opt_update=0
    opt_with_jsxhint=0

    target=all

    while [ $# -gt 0 ]; do
        case $1 in
            --with-ycm)
                opt_with_ycm=1
                ;;
            -n|--no-update)  # deprecated
                opt_update=0
                ;;
            --update)
                opt_update=1
                ;;
            --with-jsxhint)
                opt_with_jsxhint=1
                ;;
            -h|--help)
                usage
                return 0
                ;;
            -*|--*)
                usage
                return 1
                ;;
            *)
                target=$1
                ;;
        esac
        shift
    done

    return 0

    case $target in
        vim)
            info "Installing vim settings..."
            for f in _vim*; do
                link_file $f
            done
            ;;
        restore)
            info "Restoring..."
            for f in _*; do
                unlink_file $f
            done
            ;;
        all)
            info "Installing all..."
            install_prerequisites
            for f in _*; do
                link_file $f
            done
            ;;
        *)
            error "Invalid target: $target"
            usage
            return 1
            ;;
    esac

    if [ $opt_with_ycm -eq 1 ]; then
        git submodule add https://github.com/Valloric/YouCompleteMe.git _vim/bundle/YouCompleteMe
    fi

    if [ $opt_with_jsxhint -eq 1 ]; then
        install_jsxhint
    fi

    submodules=`git submodule | awk '{print $2}'`
    for x in _vim/bundle/*; do
        if ! echo "$submodules" | grep $x >/dev/null 2>&1; then
            info "Removing unused submodule: $x"
            rm -rf $x
        fi
    done

    git submodule update --init --recursive

    if [ $opt_with_ycm -eq 1 ]; then
        install_ycm
    fi

    if [ $opt_update -eq 1 ]; then
        info "Updating submodules to latest versions..."
        git submodule foreach --recursive git pull origin master
    fi
}

main $@

# Prerequisites of YouCompleteMe
# - cmake
# - build-essential
