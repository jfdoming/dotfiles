PREFIX=
if command -v brew > /dev/null; then
    PREFIX="$(brew --prefix)"
fi
if [ -f "$PREFIX/etc/bash_completion" ]; then
    . "$PREFIX/etc/bash_completion"
fi

# \[\033 ... \007\] means "set the terminal title to ..."
PS1="\[\033]0;$TITLEPREFIX:$PWD\007\]"$'\n'"\[\033[32m\]\u@\h \[\033[33m\]\w\[\033[36m\]"'$(__git_ps1)'"\[\033[0m\]"$'\n\u03bb '

if [ -f "$HOME/.crc" ]; then
    source "$HOME/.crc"
fi
