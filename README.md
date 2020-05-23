# dotfiles

## Setup on new computer

```bash
dotfiles install <git-repo-url>
```

## Operation

1. Edit a dotfile

```
editrc [index|filename]
```

2. Pull from upstream

```
dotfiles pull
```

3. Create bash script from template

```
newscript filename
```

## System maintenance

General workflows:

* `auto-update`: fetches packages in background for available upgrades
* `upgrade`: performs a system upgrade, checks for known issues
* `drive-health`: health routine for file systems / drives

Tools:

* `boot-svg`: export boot sequence to .svg/.txt
* `sp`: controls spotify playback
* `zypper-download`: downloads .rpm packages in parallel
* `zypper-changelog`: prints changelogs for updated packages

Local-specific script:

* `local-overrides`: checks for each local configuration overrides

## References

* https://news.ycombinator.com/item?id=11070797
* https://www.atlassian.com/git/tutorials/dotfiles
