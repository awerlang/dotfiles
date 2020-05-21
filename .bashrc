# There are 3 different types of shells in bash: the login shell, normal shell
# and interactive shell. Login shells read ~/.profile and interactive shells
# read ~/.bashrc; in our setup, /etc/profile sources ~/.bashrc - thus all
# settings made here will also take effect in a login shell.
#

if [[ $- != *i* ]] ; then
    return
fi

# bash options

export PAGER="less -FRS"
export MANPAGER="less -X"
export EDITOR='nano'
export VISUAL='nano'
export LESSHISTFILE=-
export NODE_REPL_HISTORY=""

HISTCONTROL=ignoreboth:erasedups
history -r ~/.bash_commands.sh
unset HISTFILE

for option in autocd dotglob extglob; do
    shopt -s $option &>/dev/null
done

complete -o default -o nospace -F _git dotfiles

# git repository status for bash prompt

powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
source /usr/share/powerline/bash/powerline.sh

# shell helpers

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ll='ls -Fhlv'
alias mkdir='mkdir -vp'
alias cp='cp -vn'
alias mv='mv -vn'
alias rm='rm -vi --one-file-system'
alias path='printf "%s\n" "$PATH" | tr -s ":" "\n"'
alias where='find . -name'
alias count='sort | uniq -c | sort -hr'
alias watch='watch --color --differences'

# zypper

alias provider='zypper search --provides --match-substrings'
alias pkg='zypper info --requires --provides --recommends --supplements --suggests'
alias dep='zypper search --requires-pkg --provides-pkg --recommends-pkg --supplements-pkg --suggests-pkg'

# tools

alias clip='xclip -selection clipboard'
alias newpasswd='read -r -n 16 pass < <(LC_ALL=C tr -dc "[:graph:]" < /dev/urandom) && echo $pass'
alias pubkey='xclip -selection clipboard < ~/.ssh/id_rsa.pub | echo "=> Public key copied to clipboard."'
alias json='cat "$1" | python -m json.tool'
alias decolorize=$'sed \'s/\x1b\[[0-9;]*m//g\''
alias shlint='ls bin/* | entr -s "shellcheck --external-sources --color=always --exclude=SC2016 bin/*"'
alias wanip4='dig @resolver1.opendns.com -4 myip.opendns.com A +short'
alias wanip6='dig @resolver1.opendns.com -6 myip.opendns.com AAAA +short'

# sudo

alias btrfs='sudo btrfs'
alias etckeeper='sudo etckeeper'
alias etcdiff='etckeeper vcs diff | delta'
alias journalctl='sudo journalctl'
alias rpmconfigcheck='sudo rpmconfigcheck'
alias snapper='sudo snapper'
alias zypper='sudo zypper'
alias visudo='sudo EDITOR=nano visudo'

alias filefrag='/usr/sbin/filefrag'

alias g='git'
complete -o default -o nospace -F _git g

diff() {
    command diff -u "$1" "$2" | delta
}

highlight() {
    grep --color=always --extended-regexp -e "^" -e "$*" | less -R
}

mkd() {
    [[ $1 ]] && mkdir "$1" && cd "$1"
}

_editrc_files() {
    dotfiles ls-files | nl -w2 -n'rz' -s' '
}

_editrc_completions() {
    if [[ "${#COMP_WORDS[@]}" != "2" ]]; then
        return
    fi

    local IFS=$'\n'
    COMPREPLY=($(compgen -W "$(_editrc_files)" --  "${COMP_WORDS[1]}"))
}

complete -F _editrc_completions editrc

# Welcome messages

welcome

# Default options for interactive mode

set -o noclobber -o pipefail
