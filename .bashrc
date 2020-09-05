if ! command -v __git_ps1 > /dev/null; then
    source $HOME/git-prompt-local.sh
fi

PS1="\[\033]0;$TITLEPREFIX:$PWD\007\]\n\[\033[32m\]\u@\h \[\033[33m\]\w\[\033[36m\]"'$(__git_ps1)'"\[\033[0m\]\n"$'\u03bb '

if [ -f "$HOME/.crc" ]; then
    source "$HOME/.crc"
fi
