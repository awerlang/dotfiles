# dotfiles

## New repository

```bash
git init --bare ~/.config/dotfiles
dotfiles config status.showUntrackedFiles no
```

## New computer

```bash
git clone --bare <git-repo-url> $HOME/.config/dotfiles
dotfiles checkout                                       # optionally, -f
dotfiles submodule update --init --recursive 
protect-config +i
```

## Alias

```bash
alias dotfiles='git --git-dir=$HOME/.config/dotfiles/ --work-tree=$HOME'
```

## Operation

1. Edit a dotfile

```
editrc [index|filename]
```

2. Pull from upstream

```
protect-config -i
dotfiles pull
protect-config +i
```

3. Create bash script from template

```
newscript filename
```

## System maintenance

General workflows:

* `auto-update.sh`: fetches packages in background for available upgrades
* `drive-health.sh`: health routine for file systems / drives
* `upgrade.sh`: performs a system upgrade, checks for known issues

Tools:

* `boot-svg.sh`: export boot sequence to .svg/.txt
* `zypper-download.sh`: downloads .rpm packages in parallel
* `zypper-changelog.sh`: prints changelogs for updated packages

Local-specific script:

* `local-overrides.sh`: checks for each local configuration overrides

## References

* https://news.ycombinator.com/item?id=11070797
* https://www.atlassian.com/git/tutorials/dotfiles
