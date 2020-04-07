journalctl -b               # log: boot
journalctl -b --grep        # log: filter
journalctl -b | highlight   # log: highlight
journalctl -b -p 0..0       # log: emerg
journalctl -b -p 0..1       # log: alert
journalctl -b -p 0..2       # log: crit
journalctl -b -p 0..3       # log: err
journalctl -b -p 0..4       # log: warning
journalctl -p               # log: priority
journalctl -u               # log: unit
dmesg -H                    # log: kernel ring
systemctl -a                # services: all
systemctl -at               # services: all of type
systemctl -a --state=failed # services: failed
systemctl status            # services: status
systemctl cat               # services: definition
systemctl list-dependencies # services: dependencies
systemctl list-dependencies --reverse # services: depend upon
systemd-analyze                 # startup
systemd-analyze critical-chain  # startup
systemd-analyze blame           # startup

zypper search                   # packages
zypper search --details         # packages
zypper search --requires --recommends --supplements --suggests                  # packages: dependencies
zypper search --requires-pkg --recommends-pkg --supplements-pkg --suggests-pkg  # packages: provides

etckeeper commit -m ''
etckeeper vcs diff $(etckeeper vcs rev-list --max-parents=0 HEAD) | fancy
etckeeper vcs log
etckeeper vcs log --oneline
etckeeper vcs log sudoers
etckeeper vcs checkout -- 
etckeeper vcs reset HEAD^
etckeeper vcs reset --hard HEAD
etckeeper vcs show HEAD | fancy
etckeeper vcs diff | fancy
etckeeper vcs status

dotfiles ls-files
dotfiles untracked
dotfiles push
dotfiles camend -a
dotfiles commit -a -m ""
dotfiles commit -a
dotfiles add -p
dotfiles add -u
dotfiles add 
dotfiles diff --staged | fancy
dotfiles diff | fancy
dotfiles status

smartctl -a /dev/nvme0n1    # storage: health
smartctl -a /dev/sda        # storage: health
smartctl --scan             # storage: health
nvme error-log              # storage: health

sudo lsblk --output=NAME,FSTYPE,LABEL,PARTLABEL,UUID,FSAVAIL,FSUSE%,MOUNTPOINT,SIZE,OWNER,GROUP,MODE,SCHED,STATE,TRAN   # storage: partitions
btrfs filesystem usage /    # storage: fs
btrfs device stats /        # storage: fs
btrfs subvolume list -pcguq -t --sort=ogen /    # storage: fs
btrfs subvolume get-default /                   # storage: fs
btrfs subvolume show /      # storage: fs
snapper -c root list        # storage: fs
filefrag                    # storage: fs
filefrag -v                 # storage: fs
du -hx -d 1 . | sort -hs    # storage: directory size

free --human    # system: free memory
uname -a        # system: label
inxi -Fxxxz     # system: properties
xrandr -q       # system: displays
xrandr --current # system: displays
xrandr --listactivemonitors # system: displays
sensors         # system: sensors
sync            # system: disk cache
ps afux | less -S # system: processes
ps -U root -u root fu | less -S # processes list user tree
ps -eo user= | sort | uniq --count | sort --reverse --numeric-sort # system: processes
pidof $PROCESS  # system: processes

sudo lspci -tv  # system: pci
sudo lsinitrd   # system: initramfs, initrd
sudo mkinitrd   # system: initramfs, initrd
sudo efibootmgr -v   # system: efi
sudo grub2-mkconfig -o /boot/grub2/grub.cfg # generate grub menu
sudo swapon --all
sudo swapoff --all

lsof # list open files
lsof +D /path # list open file directory recursive
lsof +L1 # list deleted files
lsof -i tcp # internet network
lsof -i :22 # internet port network
lsof -p $$ # files process

read -r var     # io: read into variable
read < "/path"  # io: read from file
socat
ss -ralnp -f inet
watch -n 1 -- "ss -o state established '( dport = :http or sport = :http )'"
nc -d 
nc -du 
dd if=/dev/_ of=/dev/_ iflag=direct oflag=direct bs=32M status=progress
lslocks

sudoedit /etc/fstab
sudoedit /etc/default/grub
sudoedit /etc/polkit-1/rules.d/
sudoedit /etc/X11/xorg.conf.d/50-monitor.conf
visudo -f /etc/sudoers.d/

getent passwd "$USER" | cut -d ':' -f 5 # user full name
gethostip -d example.org # dns hosts internet ipv4 decimal
host example.org
nslookup example.org

fold --width 1 <<< foo                  # text: split characters lines
sed '9d' file                           # text: delete line one-indexed
sed '/pattern/r./input.txt' example.txt # text: insert merge file pattern
sed '/^$/d' file                        # text: delete empty lines
sed '/^[[:space:]]*$/d' file            # text: delete whitespace line
sed --quiet '/^START$/,/END^$/{/^START$/d;/^END$/d;p;}' <<< $'START\nfirst\nEND\nSTART\nsecond\nEND' # text: extract delimiter lines
sort --ignore-case --human-numeric-sort source.txt  # sort: case insensitive
sort --reverse --human-numeric-sort source.txt      # sort: reverse sort
sort --unique source.txt                            # sort: unique
sort --unique --output source.txt{,}                # sort: in-place
xxd -c 48 -l 1000000 FILENAME | less    # hex view
xmllint --xpath '/root/child/@attr' -   # text: xml xpath expression

watch -- 
watch -- sensors
watch -- free --human
watch -- ps afux

curl cheat.sh   # tools: cheatsheets
curl wttr.in    # tools: weather
cal             # tools: calendar

lsattr      # files: attributes
chattr      # files: attributes
cp f{,~}    # file: backup copy

protect-config +i
protect-config -i
editrc .bashrc
editrc .bash_commands.sh
editrc 
