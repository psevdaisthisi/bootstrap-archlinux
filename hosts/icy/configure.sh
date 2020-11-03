script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

pushd "$script_path" > /dev/null

source misc.sh

_host=""
_user=""
_stepping=""
while [[ $# -gt 0 ]]
do
	case "$1" in
		-h|--host)
			_host="$2"
			shift
			shift
			;;
		-s|--stepping)
			_stepping="--stepping"
			shift
			;;
		-u|--user)
			_user="$2"
			shift
			shift
			;;
		*)
			echo "Unknown option: '$1'. Will be ignored."
			shift
			;;
	esac
done
[ -z "$_host" ] && echo "Missing mandatory '--host' option." && exit 1
[ -z "$_user" ] && echo "Missing mandatory '--user' option." && exit 1


printinfo "\n"
printinfo "+ ------------------------------- +"
printinfo "| Installing and configuring GRUB |"
printinfo "+ ------------------------------- +"
[ "$_stepping" ] && { yesno "Continue?" || exit 1; }
grub-install --target=x86_64-efi --efi-directory="/boot/efi" --bootloader-id=arch_grub --recheck && sync
cp /etc/default/grub /etc/default/grub.backup
cp sysfiles/grub /etc/default/grub
chmod u=rw,g=r,o=r /etc/default/grub

curl --connect-timeout 13 --retry 5 --retry-delay 2 \
	"https://github.com/psevdaisthisi/poly-dark/archive/master.zip" -L -o /tmp/polydark.zip
unzip /tmp/polydark.zip -d /tmp
rm /tmp/poly-dark-master/install.sh
mv /tmp/poly-dark-master /boot/grub/themes/polydark

grub-mkconfig -o /boot/grub/grub.cfg

printinfo "\n"
printinfo "+ ------------------------------------ +"
printinfo "| Configuring userspace FS encryption |"
printinfo "+ ------------------------------------ +"
[ "$_stepping" ] && { yesno "Continue?" || exit 1; }
fscrypt setup
fscrypt setup "/home/${_user}/vol1"

# Setup auto unlocking at login as described in:
# https://wiki.archlinux.org/index.php/Fscrypt#PAM_module
cp /etc/pam.d/system-login /etc/pam.d/system-login.backup
cp sysfiles/system-login /etc/pam.d/system-login
chmod u=r,g=r,o=r /etc/pam.d/system-login
cp /etc/pam.d/passwd /etc/pam.d/passwd.backup
cp sysfiles/passwd /etc/pam.d/passwd
chmod u=r,g=r,o=r /etc/pam.d/passwd

printinfo "\n"
printinfo "+ ------------------------------------------------ +"
printinfo "| Configuring mirrors, timezone, clock and locales |"
printinfo "+ ------------------------------------------------ +"
[ "$_stepping" ] && { yesno "Continue?" || exit 1; }
cp sysfiles/mirrorlist /etc/pacman.d/mirrorlist
chmod u=rw,g=r,o=r /etc/pacman.d/mirrorlist

rm -rf /etc/localtime
ln -sf /usr/share/zoneinfo/Europe/Lisbon /etc/localtime

sed -i -r '/#en_US.UTF-8 UTF-8/s/^#*//g' /etc/locale.gen
sed -i -r '/#pt_PT.UTF-8 UTF-8/s/^#*//g' /etc/locale.gen
locale-gen

{ echo "LANG=en_US.UTF-8";
  echo "LC_ALL=en_US.UTF-8";
  echo "LC_CTYPE=pt_PT.UTF-8";
  echo "LC_MEASUREMENT=pt_PT.UTF-8";
  echo "LC_MONETARY=pt_PT.UTF-8";
  echo "LC_NUMERIC=pt_PT.UTF-8";
  echo "LC_TELEPHONE=pt_PT.UTF-8";
  echo "LC_TIME=pt_PT.UTF-8"; } > /etc/locale.conf

echo "KEYMAP=pt-latin1" > /etc/rc.conf

printinfo "\n"
printinfo "+ ---------------------------- +"
printinfo "| Configuring Hostname and DNS |"
printinfo "+ ---------------------------- +"
[ "$_stepping" ] && { yesno "Continue?" || exit 1; }
echo "$_host" > /etc/hostname
{ echo -e "127.0.0.1\tlocalhost";
  echo -e "::1\tlocalhost";
  echo -e "127.0.0.1\t${_host}.localdomain\t${_host}"; } > /etc/hosts

_dns_ipv4="1.1.1.1 1.0.0.1"
_dns_ipv6="2606:4700:4700::1111 2606:4700:4700::1001"
_dns="static domain_name_servers=${_dns_ipv4} ${_dns_ipv6}"
{ echo "";
  echo "interface eno1";
  echo "${_dns}";
  echo "";
  echo "interface wlan0";
  echo "${_dns}"; } >> /etc/dhcpcd.conf

printinfo "\n"
printinfo "+ -------------------- +"
printinfo "| Configuring services |"
printinfo "+ -------------------- +"
[ "$_stepping" ] && { yesno "Continue?" || exit 1; }
systemctl enable avahi-daemon.service
systemctl enable bluetooth.service
systemctl enable dhcpcd.service
systemctl enable docker.service
systemctl enable fstrim.timer
systemctl enable iwd.service
systemctl enable rngd.service
systemctl enable sshd.service
systemctl enable thermald.service

cp /usr/share/doc/avahi/ssh.service /etc/avahi/services/
sed -i 's/hosts:.*/hosts: files mymachines myhostname mdns_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] dns/' /etc/nsswitch.conf

cp sysfiles/bluetooth.conf /etc/bluetooth/main.conf
mkdir -p /etc/iwd && cp sysfiles/iwd.conf /etc/iwd/main.conf
cp sysfiles/xorg.conf /etc/X11/xorg.conf.d/

chmod u=rw,g=r,o=r /etc/bluetooth/main.conf \
	/etc/iwd/main.conf /etc/X11/xorg.conf.d/xorg.conf

cp /etc/makepkg.conf /etc/makepkg.conf.backup
sed -i -r 's/^CFLAGS=".*"/CFLAGS="-march=native -O3 -pipe -fno-plt"/' /etc/makepkg.conf
sed -i -r 's/^CXXFLAGS=".*"/CXXFLAGS="-march=native -O3 -pipe -fno-plt"/' /etc/makepkg.conf
sed -i -r "s/^#MAKEFLAGS=\".*\"/MAKEFLAGS=\"-j$(nproc)\"/" /etc/makepkg.conf
sed -i -r 's/^COMPRESSGZ=\(.*\)/COMPRESSGZ=(pigz -c -f -n)/' /etc/makepkg.conf
sed -i -r 's/^COMPRESSBZ2=\(.*\)/COMPRESSBZ2=(pbzip2 -c -f)/' /etc/makepkg.conf
sed -i -r 's/^COMPRESSXZ=\(.*\)/COMPRESSXZ=(xz -c -z --threads=0 -)/' /etc/makepkg.conf
sed -i -r 's/^COMPRESSZST=\(.*\)/COMPRESSZST=(zstd -c -z -q --threads=0 -)/' /etc/makepkg.conf

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
sed -i -r 's/#Port 22/Port 1612/' /etc/ssh/sshd_config
sed -i -r '/#HostKey \/etc\/ssh\/ssh_host_ed25519_key/s/^#*//g' /etc/ssh/sshd_config
sed -i -r '/#PasswordAuthentication yes/s/^#*//g' /etc/ssh/sshd_config
sed -i -r '/#PermitEmptyPasswords no/s/^#*//g' /etc/ssh/sshd_config
echo -e "\nAllowUsers\t${_user}" >> /etc/ssh/sshd_config

cp /etc/sudoers /etc/sudoers.backup
{ echo "Defaults timestamp_timeout=10";
  echo "Defaults:%wheel targetpw";
  echo -e "%wheel\tALL=(ALL) ALL";
  echo "Cmnd_Alias CPUPWR = /usr/bin/cpupower";
  echo "Cmnd_Alias IOTOP = /usr/bin/iotop";
  echo "Cmnd_Alias KBDR = /usr/bin/kbdrate";
  echo "Cmnd_Alias MNT = /usr/bin/mount";
  echo "Cmnd_Alias PS = /usr/bin/ps";
  echo "Cmnd_Alias UMNT = /usr/bin/umount";
  echo "root ALL=(ALL) ALL";
  echo "${_user} ALL=(ALL) NOPASSWD: CPUPWR,IGPUFREQ,IGPUTOP,IOTOP,KBDR,MNT,PS,UMNT"; } \
	> /etc/sudoers
chown -c root:root /etc/sudoers
chmod -c 0440 /etc/sudoers

sed -i -r 's/#SystemMaxUse=/SystemMaxUse=256M/' /etc/systemd/journald.conf
sed -i -r 's/#user_allow_other/user_allow_other/' /etc/fuse.conf
echo "vm.swappiness=10" >> /etc/sysctl.d/99-swappiness.conf
echo "vm.vfs_cache_pressure=90" >> /etc/sysctl.d/99-swappiness.conf

printinfo "\n"
printinfo "+ ---------------------- +"
printinfo "| Creating user accounts |"
printinfo "+ ---------------------- +"
[ "$_stepping" ] && { yesno "Continue?" || exit 1; }
echo "/usr/bin/bash" >> /etc/shells
chsh -s "/usr/bin/bash"

useradd --create-home --groups users,wheel --shell "/usr/bin/bash" "${_user}"
passwd --delete root
passwd --delete "${_user}"

chown "${_user}:${_user}" "/home/${_user}"
chgrp users "/home/${_user}/vol1"
chmod g=rwx "/home/${_user}/vol1"

printinfo "+ ------------------------- +"
printinfo "| Configuring user accounts |"
printinfo "+ ------------------------- +"
chown "${_user}:${_user}" "${_user}/bootstrap.sh"
su -s /bin/bash -c \
	"cd /tmp/chroot/ && . \"${_user}/bootstrap.sh\" --host ${_host} --user ${_user} ${_stepping}" \
	--login ${_user}

printinfo "\n"
printinfo "+ ------------------ +"
printinfo "| Accounts passwords |"
printinfo "+ ------------------ +"
[ "$_stepping" ] && { yesno "Continue?" || exit 1; }

printwarn "Set root password!"
passwd_root_success="no"
while [ "$passwd_root_success" = "no" ]; do
	passwd root
	[ $? -eq 0 ] && passwd_root_success="yes"
done

printwarn "Set ${_user} password!"
passwd_user_success="no"
while [ "$passwd_user_success" = "no" ]; do
	passwd ${_user}
	[ $? -eq 0 ] && passwd_user_success="yes"
done

popd > /dev/null
