#!/bin/sh

dotfiles() {
    git --git-dir=$HOME/.dotfiles --work-tree=$HOME "$@"
}

suppress() {
    if [ -z "$1" ]; then
        return
    fi

    if [ ! -f "$HOME/$1" ]; then
        return
    fi

    rm $HOME/$1
    dotfiles update-index --skip-worktree $HOME/$1
}

restore() {
    if [ -z "$1" ]; then
        return
    fi

    if [ -f "$HOME/$1" ]; then
        return
    fi

    dotfiles update-index --no-skip-worktree $HOME/$1
    dotfiles checkout -- $HOME/$1
}

confirm() {
    echo -n "Please confirm that you would like to $1. [yYnN] "
    read -sn1 answer
    echo
    while true; do
        if [ "$answer" == "y" ] || [ "$answer" == "Y" ]; then
            return 0
        elif [ "$answer" == "n" ] || [ "$answer" == "N" ]; then
            return 1
        fi
        echo -n "Come again? "
        read -sn1 answer
        echo
    done
}

config_type=$($HOME/tools/sh/choose "config type" a shell os editor 3>&2 2>&1 1>&3)
echo

if [ -n "$config_type" ]; then
    case "$config_type" in
        shell)
            config=$($HOME/tools/sh/choose config a zsh bash "all shells" 3>&2 2>&1 1>&3)
            echo

            if [ -n "$config" ]; then
                case "$config" in
                    zsh)
                        if confirm "configure zsh and disable all other shell configurations"; then
                            suppress .bashrc
                            suppress .bash_profile

                            restore .zshrc

                            echo "zsh has been configured."
                        fi
                        ;;
                    bash)
                        if confirm "configure bash and disable all other shell configurations"; then
                            suppress .zshrc

                            restore .bashrc
                            restore .bash_profile

                            echo "bash has been configured."
                        fi
                        ;;
                    "all shells")
                        if confirm "enable all shell configurations"; then
                            restore .zshrc
                            restore .bashrc
                            restore .bash_profile
                            echo "All shells have been configured."
                        fi
                        ;;
                    *)
                        echo Something went wrong! >&2
                        ;;
                esac
            fi
            ;;
        os)
            config=$($HOME/tools/sh/choose config a "Windows 10" "Mac OS X" "Linux" "all OSes" 3>&2 2>&1 1>&3)
            echo

            if [ -n "$config" ]; then
                case "$config" in
                    "Windows 10")
                        if confirm "configure for Windows 10 and disable all other OS configurations"; then
                            suppress .crc-macos
                            suppress .crc-linux

                            restore .crc-win10

                            echo "Configuration complete."
                        fi
                        ;;
                    "Mac OS X")
                        if confirm "configure for Mac OS X and disable all other shell configurations"; then
                            suppress .crc-win10
                            suppress .crc-linux

                            restore .crc-macos

                            echo "Configuration complete."
                        fi
                        ;;
                    "Linux")
                        if confirm "configure for Linux and disable all other shell configurations"; then
                            suppress .crc-win10
                            suppress .crc-macos

                            restore .crc-linux

                            echo "Configuration complete."
                        fi
                        ;;
                    "all OSes")
                        if confirm "enable all OS configurations"; then
                            restore .crc-win10
                            restore .crc-macos
                            restore .crc-linux
                            echo "Configuration complete."
                        fi
                        ;;
                    *)
                        echo Something went wrong! >&2
                        ;;
                esac
            fi
            ;;
        editor)
            config_subtype=$($HOME/tools/sh/choose "config subtype" a vim 3>&2 2>&1 1>&3)
            echo

            if [ -n "$config_subtype" ]; then
                case "$config_subtype" in
                    vim)
                        if ! [ -d $HOME/.vim/bundle/Vundle.vim ]; then
                            echo Make sure Vundle was properly installed!
                            break
                        fi

                        config=$($HOME/tools/sh/choose config a enable disable 3>&2 2>&1 1>&3)
                        echo

                        if [ -n "$config" ]; then
                            case "$config" in
                                enable)
                                    if confirm "enable Vim plugins"; then
                                        restore .vimplugins
                                        vim -u $HOME/.vimplugins -c "PluginInstall" -c "PluginClean" -c "qa!" < /dev/tty
                                        echo "Vim plugins have been enabled."
                                    fi
                                    ;;
                                disable)
                                    if confirm "disable Vim plugins"; then
                                        suppress .vimplugins
                                        vim -u DEFAULTS -c "PluginInstall" -c "PluginClean" -c "qa!" < /dev/tty
                                        echo "Vim plugins have been disabled."
                                    fi
                                    ;;
                                *)
                                    echo Something went wrong! >&2
                                    ;;
                            esac
                        fi
                        ;;
                    *)
                        echo Something went wrong! >&2
                        ;;
                esac
            fi
            ;;
        *)
            echo Something went wrong! >&2
            ;;
    esac
fi
