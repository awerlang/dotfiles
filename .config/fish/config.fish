if status is-interactive
    # Commands to run in interactive sessions can go here
    complete -c dotfiles -a '(complete --do-complete "git ")'
    complete -c zypper-download -a '(complete --do-complete "zypper ")'

    abbr --add g git
    abbr --add clip fish_clipboard_copy
    abbr --add isascii iconv -f ascii -t ascii -o /dev/null
    abbr --add isutf8 iconv -f utf-8 -t utf-8 -o /dev/null
end
