# dotfiles
These are my dotfiles (e.g. .bashrc, .vimrc).

This repository uses ideas presented at the following link: https://www.atlassian.com/git/tutorials/dotfiles. Note however that the scripts included here are all created from scratch.

## Installation

Follow the instructions below to set up these dotfiles locally. The "Basic setup" instructions are mandatory (or should be replaced with the "Manual setup" instructions), and the other sections are optional depending on which features you will use.

### Basic setup

First, determine if you have `curl` or `wget` installed by typing each of those commands into your favourite shell.

Next, run the appropriate command from below depending on which of `curl` or `wget` you have installed:
- `curl https://raw.githubusercontent.com/jfdoming/dotfiles/master/tools/install.sh | sh`
- `wget -O - https://raw.githubusercontent.com/jfdoming/dotfiles/master/tools/install.sh | sh`

This will automatically download and install all dotfiles and plugins. You can view the install script before you run it [here](https://github.com/jfdoming/dotfiles/tree/master/tools/install.sh).

*Note: If you do not have either of `curl` or `wget` installed, you will need to manually download the installation script from [here](https://github.com/jfdoming/dotfiles/tree/master/tools/install.sh) and execute it, or go through the [manual setup process](#manual-setup) below.*

### Manual setup

Clone the repository: `git clone --bare https://github.com/jfdoming/dotfiles $HOME/.dotfiles`

Checkout the repository and manually resolve merge conflicts: `git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout`

Run the setup script: `$HOME/tools/setup.f.sh`

That's it!

### Setting up `vim`

If you are using `vim`, you probably want to configure `Vundle` next:

Clone `Vundle`: `git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim`

Open `vim` and install all plugins: `:PluginInstall`

Clean any existing plugins: `:PluginClean`

Restart `vim` and make sure all error messages have disappeared.

That's it!

### System-specific setup

Depending on which system you are using, you may want to enable some system-specific features and disable those for other systems. To do this, you can use the `.f` tool which should have been installed as part of the basic setup. The relevant options are:

`.f suppress <dotfile>`: Removes the named dotfile locally.

`.f restore <dotfile>`: Restores the named dotfile from the upstream.

## Usage
Beyond the standard dotfiles, there are a few custom ones you can edit/define.

`.crc`: This file contains common code for all environments (e.g. `bash`, `zsh`).

`.crc-win10`: This file contains code specific to a Windows 10 environment. For example, there are aliases for the `autojump` utility.

`.crc-macos`: This file contains code specific to a macOS environment. For example, it loads the `autojump` utility.

The `.f` command provided in the common script file `.crc` can also be used to manage all the dotfiles. Run `.f` by itself to see a list of all available commands.
