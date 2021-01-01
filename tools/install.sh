#!/bin/sh

if ! [ -d $HOME/.dotfiles ]; then
    if ! command -v git > /dev/null; then
        echo "Could not locate the git executable. Are you sure you added it to your path?"
        exit 1
    fi

    if ! git clone --bare https://github.com/jfdoming/dotfiles $HOME/.dotfiles 2> /dev/null; then
        echo "Clone failed!"
        exit 1
    fi

    echo "Clone succeeded."

    __install_files=()
    rename_file() {
        if [ -f "$1" ]; then
            mv "$1" "$1".old
            __install_files+=("$1"' -> '"$1.old")
        fi
    }

    rename_file .bashrc
    rename_file .crc
    rename_file .crc-macos
    rename_file .crc-win10
    rename_file .vimrc
    rename_file .vimplugins
    rename_file .gitattributes
    rename_file .gitignore
    rename_file README.md
    rename_file tools/setup.f.sh
    rename_file tools/install.sh

    if [ ${#__install_files[@]} -ne 0 ]; then
        echo
        echo "Renamed the following files (please migrate these files manually):"
        for file in "${__install_files[@]}"; do
            echo $__install_files
        done
    fi

    if ! git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout; then
        exit 1
    fi

    echo
    echo "Checkout succeeded."
    echo
else
    echo "Repository already cloned, skipping..."
fi

# Install custom Git prompt.
if [ -f "$HOME/git-prompt-local.sh" ]; then
    echo "Custom prompt already installed, skipping..."
else
    __install_curlcmd=

    if command -v curl > /dev/null; then
        __install_curlcmd=curl
    elif command -v wget > /dev/null; then
        __install_curlcmd=wget -O -
    fi

    if [ -n "$__install_curlcmd" ]; then
        curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh > $HOME/git-prompt-local.sh 2> /dev/null
        echo "Custom prompt installed."
    else
        echo "Failed to install custom prompt, skipping..."
    fi
fi

# Install plugins for vim.
if command -v vim > /dev/null; then
    if ! [ -d $HOME/.vim/bundle/Vundle.vim ]; then
        if ! git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim 2> /dev/null; then
            echo "Cloning Vundle failed, skipping..."
        fi
    else
        echo "Vundle already installed, skipping clone..."
    fi

    if [ -d $HOME/.vim/bundle/Vundle.vim ]; then
        vim -u $HOME/.vimplugins -c "PluginInstall" -c "PluginClean" -c "qa!" < /dev/tty

        echo "Vim plugin install succeeded."
        echo
    fi
else
    echo "Vim is not installed! If you would like to configure vim, install it and re-run this script."
fi

$HOME/tools/setup.f.sh
