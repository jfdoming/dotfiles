# Environment variables
PS1="\[\033]0;$TITLEPREFIX:$PWD\007\]\n\[\033[32m\]\u@\h \[\033[33m\]\w\[\033[36m\]`__git_ps1`\[\033[0m\]\n"$'\u03bb '

if [ -f "$HOME/.bashrc-win10" ]; then
    source "$HOME/.bashrc-win10"
fi

# Basic aliases
alias e=exit
alias c=clear
alias l=ls
alias cd..="cd .."
alias be="vim ~/.bashrc"
alias br="source ~/.bashrc"
alias bc="be && br"

# Course aliases
alias sshl="ssh jfdoming@linux.student.cs.uwaterloo.ca $@"

# VCS aliases
alias v="git"
alias vs="v status"
alias vl="v log"

va() {
    if [ -z "$@" ]; then
        v add .
    else
        v add $@
    fi
}

alias vm="v commit"
alias vr="v reset"
alias vd="v diff"
alias vR="v rebase -i"
alias vb="v branch"
alias vP="v pull"
alias vp="vP --rebase"
alias vu="v push"
alias vc="v checkout"
alias vt="v stash"
alias vta="vt apply"
