# Fedora 20 Server kickstart for XenServer
# branch: master
##########################################

# Install, not upgrade
install

# Install from a friendly mirror and add updates
#url --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-20&arch=$basearch
#url --mirrorlist=http://10.18.2.179/fedora/20/os/
#repo --name=updates

# Language and keyboard setup
lang en_US.UTF-8
keyboard us

# Configure networking without IPv6, firewall off

# for STATIC IP: uncomment and configure
# network --onboot=yes --device=eth0 --bootproto=static --ip=192.168.###.### --netmask=255.255.255.0 --gateway=192.168.###.### --nameserver=###.###.###.### --noipv6 --hos
tname=$$$

# for DHCP:
network --bootproto=dhcp --device=eth0 --onboot=on

firewall --disabled

# Set timezone
#timezone --utc Etc/UTC
timezone --utc Asia/Shanghai

# Authentication
rootpw Asdfqwerty
# if you want to preset the root password in a public kickstart file, use SHA512crypt e.g.
# rootpw --iscrypted $6$9dC4m770Q1o$FCOvPxuqc1B22HM21M5WuUfhkiQntzMuAV7MY0qfVcvhwNQ2L86PcnDWfjDd12IFxWtRiTuvO/niB0Q3Xpf2I.
authconfig --enableshadow --passalgo=sha512

# SELinux disable
selinux --disable

# Disable anything graphical
skipx
text

# Setup the disk
zerombr
clearpart --all --drives=xvda
part /boot --fstype=ext3 --size=500 --asprimary
part / --fstype=ext4 --grow --size=1024 --asprimary
bootloader --timeout=5 --driveorder=xvda --append="console=hvc0"

# Shutdown when the kickstart is done
reboot

# Minimal package set
%packages --excludedocs
@standard
@Development Tools
gcc
gcc-c++
make
openssl-devel
libxml2
libxml2-devel
libxslt
git
man
vim
wget
net-tools
NetworkManager
%end

# Copy grub.cfg to a backup and then make adaptations for buggy pygrub
%post --log=/root/ks-post.log

echo -n "Network fixes"
# initscripts don't like this file to be missing.
cat > /etc/sysconfig/network << EOF
NETWORKING=yes
NOZEROCONF=yes
EOF
echo -n "."

# For cloud images, 'eth0' _is_ the predictable device name, since
# we don't want to be tied to specific virtual (!) hardware
rm -f /etc/udev/rules.d/70*
ln -s /dev/null /etc/udev/rules.d/80-net-name-slot.rules
echo -n "."

# simple eth0 config, again not hard-coded to the build hardware
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE="eth0"
BOOTPROTO="dhcp"
ONBOOT="yes"
TYPE="Ethernet"
PERSISTENT_DHCLIENT="yes"
EOF
echo -n "."

# generic localhost names
cat > /etc/hosts << EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

EOF
echo -n "."

# since NetworkManager is disabled, need to enable normal networking
chkconfig network on
echo .

# utility script
echo -n "Utility scripts"
echo "== Utility scripts ==" >> /root/ks-post.debug.log
wget -O /opt/domu-hostname.sh https://github.com/frederickding/xenserver-kickstart/raw/develop/opt/domu-hostname.sh 2>> /root/ks-post.debug.log
chmod +x /opt/domu-hostname.sh
echo .

# remove unnecessary packages
echo -n "Removing unnecessary packages"
echo "== Removing unnecessary packages ==" >> /root/ks-post.debug.log
yum -C -y remove linux-firmware >> /root/ks-post.debug.log 2&>1
echo .

# generalization
echo -n "Generalizing"
rm -f /etc/ssh/ssh_host_*
echo .

# Install puppet
echo -n "Puppet"
rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-fedora-20.noarch.rpm
yum install -y puppet facter 2&>1
echo .

#Add install Xentools
echo -n "xe tools"
rpm -ivh http://10.18.2.179/scaleworks/deps/xe-guest-utilities-xenstore-6.2.0-1150.x86_64.rpm
rpm -ivh http://10.18.2.179/scaleworks/deps/xe-guest-utilities-6.2.0-1150.x86_64.rpm
sed -i '180s/\.\*/\:\.\*/g' /usr/sbin/xe-update-guest-attrs
sed -i '181s/addr\://g' /usr/sbin/xe-update-guest-attrs
sed -i '182s/addr\://g' /usr/sbin/xe-update-guest-attrs
service xe-linux-distribution restart
echo .


# Install latest cloud-init
echo -n "Cloud-int"
yum install -y http://10.18.2.179/scaleworks/deps/cloud-init-0.7.5-8.fc21.x86_64.rpm
wget -O /etc/cloud/cloud.cfg http://10.18.2.179/fedora/ks/cloud.cfg

echo .

#Add scaleworks
echo -n "Add scaleworks"
echo "scaleworks ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/01-scaleworks
sed -i -e 's@ requiretty@ !requiretty@' /etc/sudoers
echo .

#Add extra package
echo -n "Add packages"
yum install -y libxslt-devel ntp
echo .


# fix boot for older pygrub/XenServer
# you should comment out this entire section if on XenServer Creedence/Xen 4.4
echo -n "Fixing boot"
echo "== GRUB fixes ==" >> /root/ks-post.debug.log
cp /boot/grub2/grub.cfg /boot/grub2/grub.cfg.bak
cp /etc/default/grub /etc/default/grub.bak
cp --no-preserve=mode /etc/grub.d/00_header /etc/grub.d/00_header.bak
sed -i 's/GRUB_DEFAULT=saved/GRUB_DEFAULT=0/' /etc/default/grub
sed -i 's/default="\\${next_entry}"/default="0"/' /etc/grub.d/00_header
echo -n "."
grub2-mkconfig -o /boot/grub2/grub.cfg >> /root/ks-post.debug.log 2&>1
echo .

#Clean up
echo -n "Clean Up"
rm -rf /tmp/cloud-init-0.7.508.fc21.x86_64.rpm
sed -i -e 's@^ONBOOT="no@ONBOOT="yes@' -e 's/UUID=.*$//g' /etc/sysconfig/network-scripts/ifcfg-eth0
/bin/systemctl stop NetworkManager.service
/bin/systemctl disable NetworkManager.service


#Clean cloud-init
rm -rf /var/lib/cloud/
rm -rf /var/log/cloud-init*.log
rm -rf /run/cloud-init

# Clean files
rm -rf anaconda-ks.cfg
rm -rf ks-post.debug.log
rm -rf ks-post.log
echo .

#reboot
reboot

%end
