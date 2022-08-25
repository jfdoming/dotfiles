[ -f "$HOME/.zshauxrc.pre" ] && source "$HOME/.zshauxrc.pre"

# Expected path to the oh-my-zsh installation.
ZSH_PATH="$HOME/.oh-my-zsh"

# Move completion caches out of the home directory.
ZSH_COMPDUMP="$ZSH_PATH/cache/completions/.zcompdump"
HISTFILE="$ZSH_PATH/cache/.zsh_history"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Make sure the installation exists.
if [ -e "$ZSH_PATH/oh-my-zsh.sh" ]; then
    export ZSH="$ZSH_PATH"

    # See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
    ZSH_THEME="powerlevel10k/powerlevel10k"

    # Choose plugins for oh-my-zsh to load.
    plugins=(git gitfast zsh-autosuggestions zsh-syntax-highlighting)

    # Load oh-my-zsh.
    save_aliases=$(alias -L)
    source $ZSH/oh-my-zsh.sh

    # Get rid of the default aliases.
    unalias -m '*'
    eval $save_aliases
    unset save_aliases

    # Enable vim-style shortcuts on the command-line.
    bindkey -v
    [[ -n "$key[Home]" ]] && bindkey -- "$key[Home]" beginning-of-line
    [[ -n "$key[End]" ]] && bindkey -- "$key[End]" end-of-line
    [[ -n "$key[Insert]" ]] && bindkey -- "$key[Insert]" overwrite-mode
    [[ -n "$key[Backspace]" ]] && bindkey -- "$key[Backspace]" backward-delete-char
    [[ -n "$key[Delete]" ]] && bindkey -- "$key[Delete]" delete-char
    [[ -n "$key[Up]" ]] && bindkey -- "$key[Up]" up-line-or-history
    [[ -n "$key[Down]" ]] && bindkey -- "$key[Down]" down-line-or-history
    [[ -n "$key[Left]" ]] && bindkey -- "$key[Left]" backward-char
    [[ -n "$key[Right]" ]] && bindkey -- "$key[Right]" forward-char
    bindkey '^r' history-incremental-search-backward
fi

# Run the rest of the common setup actions.
if [ -f "$HOME/.crc" ]; then
    source "$HOME/.crc"
fi

# For iterm2 support.
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

: # Don't end on an error!
