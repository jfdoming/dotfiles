# dotfiles
These are my dotfiles (e.g. .bashrc, .vimrc).

This repository uses ideas presented at the following link: https://www.atlassian.com/git/tutorials/dotfiles. Note however that the scripts included here are all created from scratch.

## Installation

Follow the instructions below to set up these dotfiles locally. The "Basic setup" instructions are mandatory, and the other sections are optional depending on which features you will use.

### Basic setup

Clone the repository: `git clone --bare https://github.com/jfdoming/dotfiles $HOME/.dotfiles`

Checkout the repository: `git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout`

Mark the setup script as executable: `chmod +x $HOME/tools/setup.f.sh`

Run the setup script: `$HOME/tools/setup.f.sh`

That's it!

### Setting up `vim`

If you are using `vim`, you probably want to configure `Vundle` next:

Clone `Vundle`: `git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim`

Open `vim` and install all plugins: `:PluginInstall`

Restart `vim` and make sure all error messages have disappeare and make sure all error messages have disappeared.

That's it!

### System-specific setup

Depending on which system you are using, you may want to enable some system-specific features and disable those for other systems. To do this, you can use the `.f` tool which should have been installed as part of the basic setup. The relevant options are:

`.f suppress <dotfile>`: Removes the named dotfile locally.

`.f restore <dotfile>`: Restores the named dotfile from the upstream.

## Usage
Beyond the standard dotfiles, there are a few custom ones you can edit/define.

`.crc`: This file contains common code for all environments (e.g. `bash`, `zsh`).

`.crc-win10`: This file contains code specific to a Windows 10 environment. For example, there are aliases for the `autojump` utility.

The `.f` command provided in the common script file `.crc` can also be used to manage all the dotfiles. Run `.f` by itself to see a list of all available commands.
