# dotfiles
These are my dotfiles (e.g. .bashrc, .vimrc).

This repository uses ideas presented at the following link: https://www.atlassian.com/git/tutorials/dotfiles. Note however that the scripts included here are all created from scratch.

## Installation
Clone the repository: `git clone --bare https://github.com/jfdoming/dotfiles $HOME/.dotfiles`

Run the setup script: `$HOME/tools/setup.f.sh`

That's it!

## Usage
Beyond the standard dotfiles, there are a few custom ones you can edit/define.

`.crc`: This file contains common code for all environments (e.g. `bash`, `zsh`).

`.crc-win10`: This file contains code specific to a Windows 10 environment. For example, there are aliases for the `autojump` utility.

The `.f` command provided in the common script file `.crc` can also be used to manage all the dotfiles. Run `.f` by itself to see a list of all available commands.
