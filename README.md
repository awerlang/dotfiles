# New repository

```bash
git init --bare ~/.config/dotfiles
dotfiles config status.showUntrackedFiles no
```

# New computer

```bash
git clone --bare <git-repo-url> $HOME/.config/dotfiles
dotfiles checkout                                       # optionally, -f
dotfiles submodule update --init --recursive 
protect-config +i
```

# Alias

```bash
alias dotfiles='git --git-dir=$HOME/.config/dotfiles/ --work-tree=$HOME'
```

# Operation

1. Edit file

```
editrc filename
```

2. Pull from upstream

```
protect-config -i
dotfiles pull
protect-config +i
```

# References

* https://news.ycombinator.com/item?id=11070797
* https://www.atlassian.com/git/tutorials/dotfiles
