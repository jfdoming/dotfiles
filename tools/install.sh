#!/bin/sh
# Default dotfiles installation script.

# Locate a command we can use to fetch files from the internet.
__install_curlcmd=

if command -v curl > /dev/null; then
    __install_curlcmd=curl
elif command -v wget > /dev/null; then
    __install_curlcmd=wget -O -
fi

if [ -z "$__install_curlcmd" ]; then
    echo "Could not locate an executable for curl or wget. Are you sure you added it to your path?"
    exit 1
fi


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
            if [ -z "$2" ]; then
                mv "$1" "$1".old
                __install_files+=("$1"' -> '"$1.old")
            else
                mv "$1" "$2"
                __install_files+=("$1"' -> '"$2")
            fi
        fi
    }

    rename_file .bashrc
    rename_file .zshrc
    rename_file .crc
    rename_file .crc-macos
    rename_file .crc-win10
    rename_file .crc-linux
    rename_file .vimrc
    rename_file .vimplugins
    rename_file .gitattributes
    rename_file .gitconfig .gitconfig-local
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

if ! command -v zsh > /dev/null; then
    echo "Failed to locate zsh executable. Please install it first if you would like to use zsh."
else
    # Install oh-my-zsh...
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "Oh My Zsh already installed, skipping..."
    else
        sh -c "$($__install_curlcmd -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended --keep-zshrc"
    fi

    # ...and plugins...
    if [ -d ${zsh_custom:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ]; then
        echo "zsh-autosuggestions already installed, skipping..."
    else
        git clone https://github.com/zsh-users/zsh-autosuggestions ${zsh_custom:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    fi
    if [ -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting ]; then
        echo "zsh-syntax-highlighting already installed, skipping..."
    else
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    fi

    # ...and themes.
    if [ -d ${zsh_custom:-~/.oh-my-zsh/custom}/themes/powerlevel10k ]; then
        echo "powerlevel10k already installed, skipping..."
    else
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    fi

    # Finally, change the default shell to zsh.
    if echo "$SHELL" | grep -q zsh; then
        echo "The default shell is already zsh, skipping..."
    else
        echo "Changing the default shell..."
        chsh -s "$(which zsh)"
        echo "Default shell updated. You may need to reboot for the changes to take effect."
    fi
    echo
fi

# TODO install:
# 1. fzf
# 2. fd
# 3. rg
# 4. bat

$HOME/tools/setup.f.sh
