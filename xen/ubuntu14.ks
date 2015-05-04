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
user scaleworks --fullname "scaleworks" --password Asdfqwerty

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

preseed base-installer/install-recommends boolean false

#reboot server

reboot

# Minimal package set
%packages
ubuntu-minimal
openssl
wget
tcpd
openssh-server
linux-image-virtual
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

# fix boot for older pygrub/XenServer
# you should comment out this entire section if on XenServer Creedence/Xen 4.4
echo -n "Fixing boot"
cp /boot/grub/grub.cfg /boot/grub/grub.cfg.bak
cp /etc/default/grub /etc/default/grub.bak
cp --no-preserve=mode /etc/grub.d/00_header /etc/grub.d/00_header.bak
sed -i 's/GRUB_DEFAULT=saved/GRUB_DEFAULT=0/' /etc/default/grub
sed -i 's/default="\\${next_entry}"/default="0"/' /etc/grub.d/00_header
echo -n "."
cp --no-preserve=mode /etc/grub.d/10_linux /etc/grub.d/10_linux.bak
sed -i 's/${sixteenbit}//' /etc/grub.d/10_linux
echo -n "."
update-grub
echo .

echo "add repo"
cat > /etc/apt/sources.list << EOF
deb http://mirrors.yun-idc.com/ubuntu/ precise main restricted universe
deb http://mirrors.yun-idc.com/ubuntu/ precise-security main restricted universe
deb http://mirrors.yun-idc.com/ubuntu/ precise-updates main restricted universe
EOF
apt-get update
apt-get install -y cloud-init
wget -O /etc/cloud/cloud_ubuntu.cfg http://10.18.2.179/fedora/ks/cloud.cfg
echo 'datasource_list: [ NoCloud ]' | sudo -s tee /etc/cloud/cloud.cfg.d/90_dpkg.cfg
sudo dpkg-reconfigure -f noninteractive cloud-init
echo -n '.'

# Install puppet
echo -n "Puppet"
cat > /etc/apt/sources.list.d/puppetlabs.list << EOF
deb http://10.18.2.179/puppet/apt precise main
deb-src http://10.18.2.179/puppet/apt precise main
deb http://10.18.2.179/puppet/apt precise dependencies
deb-src http://10.18.2.179/puppet/apt precise dependencies
EOF
apt-get update
apt-get install -y --force-yes puppet facter

#echo -n '.'
#Disable IPV6
echo -n "Disable IPV6"
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
echo -n '.'


#Add install Xentools
echo -n "xe tools"
wget http://10.18.2.179/scaleworks/deps/xe-guest-utilities_6.2.0-1150_amd64.deb
dpkg -i xe-guest-utilities_6.2.0-1150_amd64.deb
echo "#build custom addons" >> /usr/sbin/xe-update-guest-attrs
echo "xenstore_write_cached \"attr/Customs/Kickstart\" \"0\"" >> /usr/sbin/xe-update-guest-attrs
service xe-linux-distribution restart
echo .

#Add scaleworks
sed -i -e 's@ requiretty@ !requiretty@' /etc/sudoers
echo .

# setup locales
locale-gen en_US.UTF-8
update-locale LANG="en_US.UTF-8"
echo 'LANG=en_US.UTF-8' >> /etc/environment
echo 'LC_ALL=en_US.UTF-8' >> /etc/environment

#Cleanup
#echo "Clean up"
#rm -rf /target/var/lib/cloud/
#rm -rf /target/var/log/cloud-init*.log
#rm -rf /target/run/cloud-init

# files
#rm -rf /target/root/ks-post-2.log
#rm -rf /target/root/ks-post.log
#rm -rf /target/root/ks-post.debug.log
#echo .


%end
