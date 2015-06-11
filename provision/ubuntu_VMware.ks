# Ubuntu 12 Server kickstart for XenServer
# branch: master
##########################################

# Install, not upgrade
install

# Install from a friendly mirror and add updates
#url --url http://10.18.2.179/ubuntu/os
cdrom

# Language and keyboard setup
lang en_US.UTF-8
keyboard us

# Configure networking without IPv6, firewall off

# for STATIC IP: uncomment and configure
# network --onboot=yes --device=eth0 --bootproto=static --ip=192.168.###.### --netmask=255.255.255.0 --ga
teway=192.168.###.### --nameserver=###.###.###.### --noipv6 --hostname=$$$

# for DHCP:
network --bootproto=dhcp --device=eth0

firewall --disabled

# Set timezone
#timezone --utc Etc/UTC
timezone --utc Asia/Shanghai

# Authentication
rootpw --disabled
user scaleworks --fullname "scaleworks" --password scaleworks

auth  --useshadow  --enablemd5
# if you want to preset the root password in a public kickstart file, use SHA512crypt e.g.
# rootpw --iscrypted $6$9dC4m770Q1o$FCOvPxuqc1B22HM21M5WuUfhkiQntzMuAV7MY0qfVcvhwNQ2L86PcnDWfjDd12IFxWtRi
TuvO/niB0Q3Xpf2I.
authconfig --enableshadow --passalgo=sha512

# Disable anything graphical
skipx
text


#Setup the disk
zerombr yes
clearpart --all
pressed partman-auto-lv/guided_size string 7680MB
part /boot --fstype=ext3 --size=500 --asprimary
part pv.1 --size=1 --grow --asprimary
volgroup VolGroup pv.1
logvol / --fstype=ext4 --name=lv_root --vgname=VolGroup --grow --size=1024
logvol /var --fstype=ext4 --name=lv_var --vgname=VolGroup --size=2048
logvol swap --fstype=swap --name=lv_swap --vgname=VolGroup --size=1024
#part /boot --fstype=ext3 --size=500 --asprimary
#part / --fstype=ext4 --grow --size=1024 --asprimary
bootloader --location=mbr

#reboot server

reboot

# Minimal package set
%packages
ubuntu-minimal
openssl
wget
tcpd
openssh-server
curl
screen
vim

%post

echo -n "/etc/fstab fixes"
# update fstab for the root partition
perl -pi -e 's/(errors=remount-ro)/noatime,nodiratime,$1,barrier=0/' /etc/fstab
echo .

echo -n "Network fixes"
# For cloud images, 'eth0' _is_ the predictable device name, since
# we don't want to be tied to specific virtual (!) hardware
rm -f /etc/udev/rules.d/70*
ln -s /dev/null /etc/udev/rules.d/80-net-name-slot.rules
echo .

# generic localhost names
echo "localhost" > /etc/hostname
echo .
cat > /etc/hosts << EOF
127.0.0.1 localhost
127.0.1.1 localhost

#The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

EOF
echo .

# generalization
echo -n "Generalizing"
rm -f /var/cache/apt/archives/*.deb
rm -f /var/cache/apt/*cache.bin
rm -f /var/lib/apt/lists/*_Packages
echo .

#Disable IPV6
echo -n "Disable IPV6"
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
echo -n '.'


# setup locales
locale-gen en_US.UTF-8
update-locale LANG="en_US.UTF-8"
echo 'LANG=en_US.UTF-8' >> /etc/environment
echo 'LC_ALL=en_US.UTF-8' >> /etc/environment

%end
