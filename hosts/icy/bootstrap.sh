script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

pushd "$script_path" > /dev/null

source "../../misc.sh"

_host=""
_user=""
_rootmnt="$(mktemp -d)"
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
			printwarn "Unknown option: '$1'. Will be ignored."
			shift
			;;
	esac
done
[ -z "$_host" ] && printerr "Missing mandatory '--host' option." && exit 1
[ -z "$_user" ] && printerr "Missing mandatory '--user' option." && exit 1

printinfo "\n"
printinfo "+ --------------------- +"
printinfo "| Erasing storage disks |"
printinfo "+ --------------------- +"
[ "$_stepping" ] && { yesno "Continue?" || exit 1; }
sgdisk --zap-all /dev/nvme0n1 && sleep 2

printinfo "\n"
printinfo "+ ------------------------- +"
printinfo "| Partitioning /dev/nvme0n1 |"
printinfo "+ ------------------------- +"
[ "$_stepping" ] && { yesno "Continue?" || exit 1; }
parted /dev/nvme0n1 mklabel gpt && sleep 1

_starts_at=1
_ends_at=$((1 + 384)) # 384MiB EFI partition
parted /dev/nvme0n1 mkpart primary "${_starts_at}MiB" "${_ends_at}MiB" set 1 esp on && sleep 1

_starts_at=${_ends_at}
_ends_at=$((${_ends_at} + 384)) # 384MiB boot partition
parted /dev/nvme0n1 mkpart primary "${_starts_at}MiB" "${_ends_at}MiB" && sleep 1

_starts_at=${_ends_at}
_ends_at=$((${_ends_at} + 64 * 1024)) # 96GiB root partition
parted /dev/nvme0n1 mkpart primary "${_starts_at}MiB" "${_ends_at}MiB" && sleep 1

_starts_at=${_ends_at} # All remaining space as data partition (vol1)
parted /dev/nvme0n1 mkpart primary "${_starts_at}MiB" "100%" && sleep 1
printinfo "\n"

printinfo "\n"
printinfo "+ --------------------------------------------------------------- +"
printinfo "| Formatting /dev/nvme0n1 and setting up LUKS encrypted partition |"
printinfo "+ --------------------------------------------------------------- +"
[ "$_stepping" ] && { yesno "Continue?" || exit 1; }
mkfs.fat -F32 /dev/nvme0n1p1 && sleep 1
mkfs.f2fs -f /dev/nvme0n1p2 && sleep 1

luks_format_success="no"
while [ "$luks_format_success" = "no" ]; do
	cryptsetup --verbose luksFormat /dev/nvme0n1p3
	[ $? -eq 0 ] && luks_format_success="yes"
done

luks_mount_success="no"
while [ "$luks_mount_success" = "no" ]; do
	cryptsetup open /dev/nvme0n1p3 root
	[ $? -eq 0 ] && luks_mount_success="yes"
done
sleep 1

mkfs.f2fs -O encrypt -f /dev/mapper/root && sleep 1
mkfs.f2fs -O encrypt -f /dev/nvme0n1p4 && sleep 1

printinfo "\n"
printinfo "+ ------------------- +"
printinfo "| Mounting partitions |"
printinfo "+ ------------------- +"
[ "$_stepping" ] && { yesno "Continue?" || exit 1; }
mount /dev/mapper/root "$_rootmnt" && sleep 1

mkdir -p "$_rootmnt"/boot
mount /dev/nvme0n1p2 "$_rootmnt"/boot
mkdir -p "$_rootmnt"/boot/efi
mount /dev/nvme0n1p1 "$_rootmnt"/boot/efi
mkdir -p "$_rootmnt"/home/${_user}/vol1
mount /dev/nvme0n1p4 "$_rootmnt"/home/${_user}/vol1

printinfo "\n"
printinfo "+ --------------------- +"
printinfo "| Updating mirrors list |"
printinfo "+ --------------------- +"
[ "$_stepping" ] && { yesno "Continue?" || exit 1; }
cp sysfiles/mirrorlist /etc/pacman.d/mirrorlist

printinfo "\n"
printinfo "+ --------------------- +"
printinfo "| Configuring initramfs |"
printinfo "+ --------------------- +"
[ "$_stepping" ] && { yesno "Continue?" || exit 1; }
pacstrap -i "$_rootmnt" mkinitcpio --noconfirm
cp "$_rootmnt"/etc/mkinitcpio.conf "$_rootmnt"/etc/mkinitcpio.conf.backup

_initramfs_modules=""
_initramfs_hooks="base autodetect udev keyboard keymap consolefont encrypt modconf block filesystems"
sed -i -r "s/^MODULES=\(\)/MODULES=($_initramfs_modules)/" "$_rootmnt"/etc/mkinitcpio.conf
sed -i -r "s/^HOOKS=(.*)/HOOKS=($_initramfs_hooks)/" "$_rootmnt"/etc/mkinitcpio.conf
sed -i -r '/#COMPRESSION="lz4"/s/^#*//g' "$_rootmnt"/etc/mkinitcpio.conf

# The keymap needs to be configured earlier so initramfs uses the correct layout
# for entering the disk decryption password.
mkdir -p "$_rootmnt"/usr/local/share/kbd/keymaps
{ echo "keycode 58 = Escape";
  echo "altgr keycode 18 = euro";
  echo "altgr keycode 46 = cent"; } > "$_rootmnt"/usr/local/share/kbd/keymaps/uncap.map
{ echo "keycode 58 = Caps_Lock";
  echo "altgr keycode 18 = euro";
  echo "altgr keycode 46 = cent"; } > "$_rootmnt"/usr/local/share/kbd/keymaps/recap.map
{ echo "KEYMAP=pt-latin1";
  echo "KEYMAP_TOGGLE=/usr/local/share/kbd/keymaps/uncap.map";
  echo "FONT=ter-116n"; } > "$_rootmnt"/etc/vconsole.conf

printinfo "\n"
printinfo "+ -------------------------- +"
printinfo "| Installing Pacman packages |"
printinfo "+ -------------------------- +"
[ "$_stepping" ] && { yesno "Continue?" || exit 1; }
_pkgs_base=(base amd-ucode linux-lts linux-firmware)
_pkgs_drivers=(libva libva-mesa-driver mesa mesa-vdpau ntfs-3g vulkan-radeon
               xf86-video-amdgpu)
_pkgs_sys=(atk avahi bash bluez brightnessctl coreutils dhcpcd efibootmgr
           exfat-utils f2fs-tools fakeroot findutils fish fscrypt gptfdisk
           grub iwd lz4 nss-mdns pacman parted patch pulseaudio rng-tools
           sudo wireguard-lts xz zip zstd)
_pkgs_tools=(archiso aria2 bash-completion bat bc bluez-utils cpupower croc curl
             entr exa fd ffmpeg firejail fwupd fzf gawk gnupg gocryptfs go-ipfs
             htop inotify-tools iotop libva-utils lshw lsof man neovim nmap nnn
             openbsd-netcat openssh os-prober p7zip pbzip2 pigz powertop progress
             ripgrep samba svt-av1 svt-hevc svt-vp9 thermald tigervnc time tmux
             tree turbostat unzip usbutils usleep vdpauinfo which xdg-user-dirs)
_pkgs_dev=(afl autoconf automake binaryen binutils bison clang cmake ctags
           diffutils docker docker-compose edk2-ovmf gcc gcc8 gcc9 gdb git go
           go-tools lldb ltrace m4 make man-pages ninja openssl-1.0 perf pgadmin4
           pkgconf postgresql python python-pip qemu qemu-arch-extra
           spirv-llvm-translator spirv-headers spirv-tools strace tokei
           vulkan-extra-layers vulkan-extra-tools vulkan-headers vulkan-icd-loader
           vulkan-mesa-layers vulkan-tools vulkan-validation-layers wabt zig)
_pkgs_x11=(bspwm dunst picom sxhkd xclip xorg-server xorg-xinit xorg-xinput
           xorg-xprop xorg-xrandr xorg-xset xorg-xsetroot)
_pkgs_fonts=(noto-fonts noto-fonts-emoji terminus-font ttf-font-awesome
             ttf-jetbrains-mono)
_pkgs_apps=(alacritty arandr feh firefox libreoffice-still maim meld mesa-demos
            mpv nomacs obs-studio pavucontrol pinta rofi redshift signal-desktop
            slock sxiv thunar veracrypt wireshark-qt)

pacman -Syy
pacstrap -i "$_rootmnt" ${_pkgs_base[*]} ${_pkgs_drivers[*]} ${_pkgs_sys[*]} \
	${_pkgs_tools[*]} ${_pkgs_dev[*]}  ${_pkgs_x11[*]} ${_pkgs_fonts[*]} \
	${_pkgs_apps[*]} --needed --noconfirm

printinfo "\n"
printinfo "+ ---------------- +"
printinfo "| Setting up fstab |"
printinfo "+ ---------------- +"
[ "$_stepping" ] && { yesno "Continue?" || exit 1; }
cp sysfiles/fstab "$_rootmnt"/etc/fstab
sed -i -r "s/<username>/${_user}/" "$_rootmnt"/etc/fstab
chmod u=r,g=r,o=r "$_rootmnt"/etc/fstab

printinfo "\n"
printinfo "+ ---------------------------- +"
printinfo "| Jumping into the chroot jail |"
printinfo "+ ---------------------------- +"
mkdir -p "$_rootmnt"/tmp/chroot
cp sysfiles/resolv.conf "$_rootmnt"/etc/resolv.conf
cp -r {.,../../misc.sh,../../users/${_user}} "$_rootmnt"/tmp/chroot
mount -t proc /proc "$_rootmnt"/proc/
mount --rbind /sys "$_rootmnt"/sys/
mount --rbind /dev "$_rootmnt"/dev/
chroot "$_rootmnt" /usr/bin/bash /tmp/chroot/configure.sh --host ${_host} --user ${_user} ${_stepping}

printinfo "\n"
printinfo "+ --------------------- +"
printinfo "| Unmounting partitions |"
printinfo "+ --------------------- +"
[ "$_stepping" ] && { yesno "Continue?" || exit 1; }
umount "${_rootmnt}/home/${_user}/vol1"
umount "$_rootmnt"/boot/efi
umount "$_rootmnt"/boot
sync
umount "$_rootmnt"/proc/
umount "$_rootmnt"/sys/
umount "$_rootmnt"/dev/
umount "$_rootmnt"
cryptsetup close root

popd > /dev/null
