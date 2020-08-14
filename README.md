# dotfiles

## Setup on new computer

```bash
git clone <git-repo-url>
./dotfiles/bin/dotfiles install <git-repo-url>
```

## Operation

1. Pull from upstream

```
dotfiles pull
```

2. Edit a dotfile

```
editrc [index|filename]
```

3. Create bash script from template

```
newscript filename
```

## System maintenance

General maintenance:

* `auto-update`: fetches packages in background for available upgrades
* `upgrade`: performs a system upgrade, checks for known issues
* `drive-health`: health routine for file systems / drives
* `backup`: makes a backup from a btrfs subvolume to external drive

System utilities:

* `boot-svg`: export boot sequence to .svg/.txt
* `zypper-download`: downloads .rpm packages in parallel
* `zypper-changelog`: prints changelogs for updated packages

Tools:

* `delta`: a viewer for git and diff output
* `notes`: write a note
* `serve`: serve HTTP content out of a directory
* `sp`: controls spotify playback
* `up`:  tool for writing Linux pipes with instant live preview 

Local-specific script:

* `local-overrides`: checks for each local configuration overrides

## References

* https://news.ycombinator.com/item?id=11070797
* https://www.atlassian.com/git/tutorials/dotfiles
