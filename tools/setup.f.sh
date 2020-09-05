#/bin/bash

if ! command -v git > /dev/null; then
    echo "Could not locate the git executable. Are you sure you added it to your path?"
    exit 1
fi

dotfiles() {
    git --git-dir=$HOME/.dotfiles --work-tree=$HOME "$@"
}

if ! dotfiles checkout; then
    # Failed!
    echo "Failed to checkout repository! Remove any existing dotfiles and try again."
    exit 1
fi

dotfiles config --local status.showUntrackedFiles no

echo "Setup finished. You can now use your dotfiles as normal!"
echo "You can use the \`.f\` command to update your dotfiles."
