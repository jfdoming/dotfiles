#/bin/bash

if ! command -v git > /dev/null; then
    echo "Could not locate the git executable. Are you sure you added it to your path?"
    exit 1
fi

if ! git clone --bare https://github.com/jfdoming/dotfiles $HOME/.dotfiles 2> /dev/null; then
    echo "Clone failed!"
    exit 1
fi

echo "Clone succeeded."

files=()
rename_file() {
    if [ -f "$1" ]; then
        mv "$1" "$1".old
        files+=("$1"' -> '"$1.old")
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

if [ ${#files[@]} -ne 0 ]; then
    echo
    echo "Renamed the following files:"
    for file in "${files[@]}"; do
        echo $file
    done
    echo "Please migrate these files manually."
fi

if ! git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout; then
    exit 1
fi

echo
echo "Checkout succeeded."

echo
if [ -f "$HOME/git-prompt-local.sh" ]; then
    echo "Custom prompt already installed, skipping..."
else
    curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh > $HOME/git-prompt-local.sh 2> /dev/null
    echo "Custom prompt installed."
fi

# Install Vundle (for vim).
if ! git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim 2> /dev/null; then
    echo "Cloning Vundle failed, skipping..."
    exit 1
fi

vim -u $HOME/.vimplugins -c "PluginInstall" -c "qa!" < /dev/tty

echo
echo "Vim Plugin install succeeded."
echo

$HOME/tools/setup.f.sh
