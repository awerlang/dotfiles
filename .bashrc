# There are 3 different types of shells in bash: the login shell, normal shell
# and interactive shell. Login shells read ~/.profile and interactive shells
# read ~/.bashrc; in our setup, /etc/profile sources ~/.bashrc - thus all
# settings made here will also take effect in a login shell.
#

if [[ $- != *i* ]] ; then
    return
fi

# bash options

export PAGER="less -RS"
export MANPAGER="less -X -j3"
export EDITOR='micro'
export VISUAL='micro'
export LESSHISTFILE=-
export NODE_REPL_HISTORY=""
export FZF_DEFAULT_COMMAND="fd --type file --color=always"
export FZF_DEFAULT_OPTS="--ansi"

HISTCONTROL=ignoreboth:erasedups
history -r ~/.bash_commands.sh
unset HISTFILE

for option in autocd dotglob extglob; do
    shopt -s $option &>/dev/null
done

__git_complete dotfiles __git_main
complete -o default -o nospace -F _zypper zypper-download

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
alias la='ls -Fhlva --color=auto'
alias ll='ls -Fhlv --color=auto'
alias mkdir='mkdir -vp'
alias cp='cp -vi'
alias mv='mv -vi'
alias rm='rm -vi --one-file-system'
alias path='printf "%s\n" "$PATH" | tr -s ":" "\n"'
alias where='find . -name'
alias count='sort | uniq -c | sort -hr'
alias watch='watch --color --differences'
alias uniqall='awk "!_[\$0]++"'

# rpm/zypper

alias provider='zypper search --provides --match-substrings'
alias pkg='zypper info --requires --provides --recommends --supplements --suggests'
alias dep='zypper search --requires-pkg --provides-pkg --recommends-pkg --supplements-pkg --suggests-pkg'
alias rpmkeys='rpm -q gpg-pubkey --qf "%{name}-%{version}-%{release} --> %{summary}\n"'

# tools

alias clip='xclip -selection clipboard'
alias newpasswd='read -r -n 16 pass < <(LC_ALL=C tr -dc "[:graph:]" < /dev/urandom) && echo $pass'
alias pubkey='xclip -selection clipboard < ~/.ssh/id_rsa.pub | echo "=> Public key copied to clipboard."'
alias json='python -m json.tool <'
alias up='TERM=xterm up'
alias decolorize=$'sed \'s/\x1b\[[0-9;]*m//g\''
alias shlint='ls bin/* | entr -s "shellcheck --external-sources --source-path=$HOME --color=always --exclude=SC2016 bin/*"'
alias browse='fzf --preview "bat --style=numbers --color=always {}"'
alias wanip4='dig @resolver1.opendns.com -4 myip.opendns.com A +short'
alias wanip6='dig @resolver1.opendns.com -6 myip.opendns.com AAAA +short'
alias ipv6_on='sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0'
alias ipv6_off='sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1'
alias lsint='watch -d -n 5 cat /proc/interrupts'

# sudo

alias btrfs='sudo btrfs'
alias etckeeper='sudo etckeeper'
alias etcdiff='etckeeper vcs diff | delta --navigate'
alias rpmconf='sudo rpmconf'
alias rpmconfigcheck='sudo rpmconfigcheck'
alias snapper='sudo snapper'
alias zypper='sudo zypper'
alias visudo='sudo visudo'
alias backup='sudo ~/bin/backup'

alias filefrag='/usr/sbin/filefrag'

alias g='git'
__git_complete g __git_main

diff() {
    command diff -u "$1" "$2" | delta
}

highlight() {
    grep --color=always --extended-regexp -e "^" -e "$*" | less -R
}

timeit() {
    "$@" 2>&1 | awk '{ print strftime("[%Y-%m-%d %H:%M:%S]"), $0 }'
}

mkd() {
    [[ $1 ]] && mkdir "$1" && cd "$1"
}

duh() {
    local path="$1"
    local pattern="$2"
    du $(find "$path" -name "$pattern") | awk '{total += $1} END {print total "K"}'
}

tldr() {
    command tldr --color=always "$@" | less -F
}

edit() {
    $EDITOR "$(browse)"
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

return
