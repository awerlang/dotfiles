# There are 3 different types of shells in bash: the login shell, normal shell
# and interactive shell. Login shells read ~/.profile and interactive shells
# read ~/.bashrc; in our setup, /etc/profile sources ~/.bashrc - thus all
# settings made here will also take effect in a login shell.
#

if [[ $- != *i* ]] ; then
    return
fi

# bash options

export MANPAGER="less -X"
export EDITOR='nano'
export VISUAL='nano'

HISTCONTROL=ignoreboth:erasedups
HISTFILE=~/.bash_commands.sh

for option in autocd dotglob extglob; do
    shopt -s $option &> /dev/null
done

# dotfiles with bare git repository on home directory

function dotfiles {
    git --git-dir=$HOME/.config/dotfiles/ --work-tree=$HOME $@
}

complete -o default -o nospace -F _git dotfiles

export PS1='`if [ $? = 0 ]; then echo "\[\033[01;32m\]✔"; else echo "\[\033[01;31m\]✘"; fi` \[\033[38;5;250m\]\t\[$(tput sgr0)\]\[\033[38;5;15m\] \u@\h:\[$(tput sgr0)\]\[\033[38;5;250m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\] \\$\[$(tput sgr0)\] '

# git repository status for bash prompt

if [ -f "$HOME/.config/bash-git-prompt/gitprompt.sh" ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    source $HOME/.config/bash-git-prompt/gitprompt.sh
fi

# shell helpers

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ls='ls -Fhlv --color=auto'
alias lsc='ls -Fhlv --color=always'
alias mkdir='mkdir -vp'
alias cp='cp -v'
alias mv='mv -v'
alias rm='rm -vi'
alias path='echo $PATH | tr -s ":" "\n"'
alias where='find . -name'
alias count='sort | uniq -c | sort -hr'
alias watch='watch --color --differences'

# zypper

alias provider='zypper search --provides --match-substrings'
alias pkg='zypper info --requires --provides --recommends --supplements --suggests'
alias dep='zypper search --requires-pkg --provides-pkg --recommends-pkg --supplements-pkg --suggests-pkg'

# tools

alias newpasswd='pwgen -cnys1 16'
alias pubkey='xclip -sel clip < ~/.ssh/id_rsa.pub | echo "=> Public key copied to clipboard."'
alias fancy='$HOME/.config/diff-so-fancy/diff-so-fancy | less -FRSX'
alias json='cat $1 | python -m json.tool'

# sudo

alias btrfs='sudo btrfs'
alias etckeeper='sudo etckeeper'
alias etcdiff='etckeeper vcs diff | fancy'
alias journalctl='sudo journalctl'
alias rpmconfigcheck='sudo rpmconfigcheck'
alias snapper='sudo snapper'
alias zypper='sudo zypper'
alias visudo='sudo EDITOR=nano visudo'

alias filefrag='/usr/sbin/filefrag'

alias g='git'
complete -o default -o nospace -F _git g

diff () {
    command diff -u $1 $2 | fancy
}

highlight () {
    grep --color=always --extended-regexp -e "^" -e $* | less -R
}

# Advanced directory creation
mkd () {
    [[ $1 ]] && mkdir "$1" && cd "$1"
}

extract () {
    if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2)   tar xjf $1     ;;
        *.tar.gz)    tar xzf $1     ;;
        *.bz2)       bunzip2 $1     ;;
        *.rar)       unrar x $1     ;;
        *.gz)        gunzip $1      ;;
        *.tar)       tar xf $1      ;;
        *.tbz2)      tar xjf $1     ;;
        *.tgz)       tar xzf $1     ;;
        *.zip)       unzip $1       ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7z x $1        ;;
        *)           echo "'$1' cannot be extracted via extract()" ;;
       esac
     else
         echo "'$1' is not a valid file"
     fi
}

# simple file server over HTTP
serve () {
    port=${1:-8000}
    sleep 1 && firefox localhost:$port &
    python3 -m http.server $port
}

# add/remove immutable flag to version-controlled files
protect-config () {
    FLAG=$1
    FILES=$(dotfiles ls-files | xargs -I @ -- find @ -type f | xargs echo)
    lsattr $FILES
    if [ "$FLAG" ]; then
        sudo chattr $FLAG $FILES
    fi
}

editrc () {
    sudo chattr -i $1
    nano $1
    sudo chattr +i $1
}
