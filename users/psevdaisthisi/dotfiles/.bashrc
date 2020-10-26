PS1="\[$(tput setaf 5)\]\A\[$(tput sgr0)\] \w$([ -n "$NNNLVL" ] && echo " nnn:$NNNLVL") \[$(tput setaf 6)\]➤ \[$(tput sgr0)\] "

. "$HOME/.env.sh"
. "$HOME/.bashrc.host"
[ ! -v NVM_BIN ] && [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -r "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

set_vte_theme () {
	if [ "$TERM" = "linux" ]; then
		[ -f "$HOME/.cache/wal/colors-tty.sh" ] && \
			. "$HOME/.cache/wal/colors-tty.sh"
		[ -n "$VTFONT" ] && setfont "$VTFONT"
	fi
}
set_vte_theme

# Based on https://github.com/mrzool/bash-sensible
# ------------------------------------------------
if [[ $- == *i* ]]; then
	shopt -s checkwinsize
	PROMPT_DIRTRIM=3
	bind Space:magic-space
	shopt -s globstar 2> /dev/null
	shopt -s nocaseglob
	bind "set blink-matching-paren on"
	bind "set colored-completion-prefix on"
	bind "set colored-stats on"
	bind "set completion-ignore-case on"
	bind "set completion-map-case on"
	bind "set editing-mode vi"
	bind "set keymap vi"
	bind "set mark-symlinked-directories on"
	bind "set show-all-if-ambiguous on"
	bind "set show-mode-in-prompt on"
	bind "set visible-stats on"
	bind "set vi-cmd-mode-string $(tput setaf 4)cmd $(tput sgr0)"
	bind "set vi-ins-mode-string"
	shopt -s histappend
	shopt -s cmdhist
	PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a"
	bind '"\e[A": history-search-backward'
	bind '"\e[B": history-search-forward'
	bind '"\C-p": history-search-backward'
	bind '"\C-n": history-search-forward'
	bind '"\e[C": forward-char'
	bind '"\e[D": backward-char'
	shopt -s autocd 2> /dev/null
	shopt -s direxpand 2> /dev/null
	shopt -s dirspell 2> /dev/null
	shopt -s cdspell 2> /dev/null
	CDPATH="."
	shopt -s cdable_vars
fi

export CLICOLOR=1
export EDITOR="nvim"
export HISTSIZE=32768
export HISTFILESIZE=32768
export HISTCONTROL=ignoreboth:ereasedups
export HISTIGNORE="?:??:???:????:?????"
export HISTTIMEFORMAT="%F %T "
export LESSCHARSET=UTF-8
[[ ! "$PATH" =~ $HOME/.local/bin ]] && export PATH="$PATH:$HOME/.local/bin"
[[ ! "$PATH" =~ $GOBIN ]] && export PATH="$PATH:$GOBIN"

alias aria2c="aria2c --async-dns=false"
alias beep="tput bel"
alias less="bat"
alias l="exa -1"
alias la="exa -1a"
alias lar="exa -1aR"
alias lh="exa -1ad .??*"
alias ll="exa -lh"
alias lla="exa -ahl"
alias llar="exa -ahlR"
alias llh="exa -adhl .??*"
alias llr="exa -lhR"
alias lr="exa -1R"
alias ls="exa"
alias lsa="exa -ah"
alias n="nvim"
alias nn="nvim -Zn -u NONE -i NONE"
alias q="exit"

clear-cache () {
	sync && echo 1 | sudo tee /proc/sys/vm/drop_caches &> /dev/null &&
		echo "System cache was cleared."
}

clear-shada () {
	rm -f ~/.local/share/nvim/shada/*.shada
}

clear-clipboard () {
	xclip -selection clipboard -in /dev/null
	xclip -selection primary -in /dev/null
	xclip -selection secondary -in /dev/null
}

clipit () {
	if [ -f "$1" ]; then
		local mimetype="$(file --brief --mime-type "$1")"
		[ "$mimetype" = "text/plain" ] && xclip -selection clipboard -in "$1"
		[ "$mimetype" != "text/plain" ] && xclip -selection clipboard -target "$mimetype" -in "$1"
	fi
}

energypolicy () {
	if [ "$1" = "default" ]; then
		bash "$XDG_CONFIG_HOME/.energypolicy.sh" default
	elif [ "$1" = "performance" ]; then
		bash "$XDG_CONFIG_HOME/.energypolicy.sh" performance
	elif [ "$1" = "balanced" ]; then
		bash "$XDG_CONFIG_HOME/.energypolicy.sh" balanced
	elif [ "$1" = "powersave" ]; then
		bash "$XDG_CONFIG_HOME/.energypolicy.sh" powersave
	elif [ -n "$1" ]; then
			echo "Invalid profile $1. Usage: energypolicy [default|performance|balanced|powersave]."
			return
	else
		[ -f "$XDG_CONFIG_HOME/.energypolicy" ] && \
			echo "Current profile is" $(tail -n 1 "$XDG_CONFIG_HOME/.energypolicy") || \
			echo "No profile is currently set. Usage: energypolicy [default|performance|balanced|powersave]"
		return
	fi
}

mkcd () {
	mkdir -p "$1"
	cd "$1"
}

mnt () {
	# 1. List all partitons
	# 2. Grep the ones that aren't mounted
	# 3. Send them to `fzf'
	# 4. Grab de selectd partition
	local part=$(lsblk --list --output NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT |
		grep 'part[[:space:]]*$' | grep --invert-match 'crypto_LUKS' |
		awk '{printf "/dev/%s %s %s\n",$1,$2,$3}' |
		fzf --reverse | awk '{print $1}')
	[ -z "$part" ] && return

	# Find the directories at $MOUNT that aren't already used as a mount point.
	# Taken from: https://catonmat.net/set-operations-in-unix-shell
	# local mountpoint=$(comm -23 <(/bin/ls -1Ld $MOUNT/* | sort) \
	# 	<(mount | awk '{print $3}' | sort) | fzf)
	# [ -z $mountpoint ] && return

	local mountpoint="${MOUNT}/mnt$(($(/usr/bin/ls -1 $MOUNT | grep '^mnt*' | wc -l) + 1))"
	mkdir -p "$mountpoint" || { echo "Failed to directory for mount point: '$mountpoint'" && exit 1; }

	sudo mount -o gid=users,fmask=113,dmask=002,flush "$part" "$mountpoint" 2> /dev/null ||
	sudo mount -o flush "$part" "$mountpoint"
	local res=$?

	[ $res -eq 0 ] && echo "Disk mounted at '$mountpoint'." &&
	printf "$mountpoint" | xclip -selection clipboard -in &&
	[ "$1" = "--cd" ] && cd "$mountpoint"

	[ $res -ne 0 ] && rmdir "$mountpoint" && echo "Failed to mount '$part'."
}

mnt-gocrypt () {
	[ ! -d "$1"	] && echo "Usage: mnt-gocrypt <cypherdir>" && exit 1

	local mountpoint="${MOUNT}/gocrypt$(($(/usr/bin/ls -1 $MOUNT | grep '^gocrypt*' | wc -l) + 1))"
	mkdir -p "$mountpoint" || { echo "Failed to create directory for mount point: '$mountpoint'" && exit 1; }

	# gocryptfs -allow_other "$1" "$mountpoint" && echo "Disk mounted at $mountpoint" ||
	gocryptfs "$1" "$mountpoint"
	local res=$?

	[ $res -eq 0 ] && echo "Gocrypt folder mounted at '$mountpoint'." &&
	printf "$mountpoint" | xclip -selection clipboard -in &&
	[ "$2" = "--cd" ] && cd "$mountpoint"

	[ $res -ne 0 ] && rmdir "$mountpoint" && echo "Failed to mount '$1'."
}

mnt-vcrypt () {
	[ ! -f "$1" ] && echo "Usage: mnt-vcrypt <veracrypt-file>" && exit 1

	local mountpoint="${MOUNT}/vcrypt$(($(/usr/bin/ls -1 $MOUNT | grep '^vcrypt*' | wc -l) + 1))"
	mkdir -p "$mountpoint" || { echo "Failed to create directory for mount point: '$mountpoint'" && exit 1; }

	veracrypt --text --keyfiles="" --pim=0 --protect-hidden=no "$1" "$mountpoint"
	local res=$?

	[ $res -eq 0 ] && echo "Veracrypt folder mounted at '$mountpoint'." &&
	printf "$mountpoint" | xclip -selection clipboard -in &&
	[ "$2" = "--cd" ] && cd "$mountpoint"

	[ $res -ne 0 ] && rmdir "$mountpoint" && echo "Failed to mount '$1'."
}

qemu-create () {
	if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		echo "qemu-create <volume-name> <volume-size><G|M|K>"
		echo "example: qemu-create vm1 16G"
		exit 0;
	fi

	[ -z "$1" ] && echo "ERROR: missing volume name." && exit 1
	[ -z "$2" ] && echo "ERROR: missing volume size." && exit 1

	qemu-img create -f qcow2 "$1".img.qcow2 "$2"
}

qemu-snapshot () {
	if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		echo "qemu-snapshot <source-volume> <snapshot-volume-name>"
		echo "example: qemu-snapshot vm1 vm1-snapshot"
		exit 0;
	fi

	[ ! -f "$1" ] && echo "ERROR: missing or invalid source volume." && exit 1
	[ ! -z "$2" ] && echo "ERROR: missing snapshot volume name." && exit 1

	qemu-img create -f qcow2 -b "$(pwd)/$2" "$(pwd)/$3";
}

qemu-start () {

	local cdroms=()
	local volumes=()

	local num_cpu_cores=""
	local ram_size=""

	local ssh_port=""
	local enable_igvt=false

	local firmware_type="bios"
	local guest_type="linux"

	while [[ $# -gt 0 ]]
	do
		case "$1" in
			-h|--help)
				echo "qemu-start -n|--num-cpu-cores <n> -r|--ram-size <n><K|G|T> -s|--ssh-port <n>"
				echo "[-c|--cdrom <cdrom-file>]"
				echo "[-f|--firmware-type bios|uefi (default $firmware_type)]"
				echo "[-g|--guest-type linux|windows (default $guest_type)]"
				echo "[-v|--volume <volume-file>]"
				echo "[--enable-igvt]"
				exit 0
				;;
			-c|--cdrom)
				cdroms=(${cdroms[@]} "$2")
				shift
				shift
				;;
			-f|--firmware-type)
				firmware_type="$2"
				shift
				shift
				;;
			-g|--guest-type)
				guest_type="$2"
				shift
				shift
				;;
			-n|--num-cpu-cores)
				num_cpu_cores="$2"
				shift
				shift
				;;
			-r|--ram-size)
				ram_size="$2"
				shift
				shift
				;;
			-s|--ssh-port)
				ssh_port="$2"
				shift
				shift
				;;
			-v|--volume)
				volumes=(${volumes[@]} "$2")
				shift
				shift
				;;
			--enable-igvt)
				enable_igvt=true
				shift
				;;
			*)
				echo "Unknown option: '$1'. Will be ignored."
				shift
				;;
		esac
	done

	$($enable_igvt) &&
	echo "Creating iGVT device..." &&
	local igvt_dev_uuid="$(uuidgen)" &&
	echo "$igvt_dev_uuid" | sudo tee -a "/sys/devices/pci0000:00/0000:00:02.0/mdev_supported_types/i915-GVTg_V5_4/create" > /dev/null &&
	local qemu_igvt_device="-device vfio-pci,sysfsdev=/sys/bus/mdev/devices/$igvt_dev_uuid,display=on,x-igd-opregion=on,ramfb=on,driver=vfio-pci-nohotplug"

	$([ $($enable_igvt) ] && echo "sudo ") \
	qemu-system-x86_64 -enable-kvm -machine q35 -m "$ram_size" \
		$([ "$guest_type" = "linux" ] && echo "-cpu max" ) \
		$([ "$guest_type" = "windows" ] && echo "-cpu max,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time") \
		$([ "$firmware_type" = "uefi" ] && echo "-drive file="/usr/share/edk2-ovmf/x64/OVMF_CODE.fd",if=pflash,format=raw,readonly=on") \
		$([ "$firmware_type" = "uefi" ] && echo "-drive file="/usr/share/edk2-ovmf/x64/OVMF_VARS.fd",if=pflash,format=raw,readonly=on") \
		-smp "cores=$num_cpu_cores" \
		-device intel-iommu,caching-mode=on \
		-device virtio-balloon \
		$([ $($enable_igvt) ] && echo "$qemu_igvt_device") \
		-object rng-random,filename=/dev/random,id=rng0 -device virtio-rng-pci,id=rng0 \
		$([ $($enable_igvt) ] && echo "-vga none -display gtk,gl=on") \
		$([ ! $($enable_igvt) ] && echo "-vga virtio -display gtk,gl=on") \
		-usb -device usb-tablet \
		-boot order=dc,menu=on \
		$(for v in ${volumes[@]}; do echo "-drive file=$v,format=qcow2,if=virtio,aio=native,cache.direct=on"; done) \
		$(for i in ${!cdroms[@]}; do echo "-drive file=${cdroms[$i]},index=$(($i + 2)),media=cdrom,readonly=on"; done) \
		-nic user,model=virtio-net-pci,hostfwd=tcp::"$ssh_port"-:22,smb=$(pwd)

	$($enable_igvt) &&
		echo "Destroying iGVT device..." &&
		echo 1 | sudo tee -a "/sys/bus/pci/devices/0000:00:02.0/${igvt_dev_uuid}/remove" > /dev/null
}

random-wallpaper () {
	if [ -n "$DISPLAY" ]; then
		local hour=$(date '+%H')
		local tod=""

		if [ $hour -ge 6 ] && [ $hour -lt 14 ]; then
			tod="06"
		elif [ $hour -ge 14 ] && [ $hour -lt 20 ]; then
			tod="14"
		else
			tod="20"
		fi

		local img=$(ls "$WALLPAPERS/$tod" | shuf -n 1)
		feh --bg-fill "$WALLPAPERS/$tod/$img"
	else
		echo "You're not running a graphical session."
	fi
}

screenshot () {
	if [ -n "$DISPLAY" ]; then
		local filename=$(echo screenshot-$(date '+%Y.%m.%d-%H.%M.%S'))

		maim --hidecursor --nokeyboard --quality 10 --select "$JUNK/${filename}.png" &&
		clipit "$JUNK/${filename}.png"

		[ -f "$JUNK/$filename".png ] &&
		echo Image written to "$JUNK/${filename}.png" &&
		notify-send 'Screenshot' "File available at '$JUNK/${filename}.png'"
	fi
}

secrm () {
	if [ $# -gt 0 ]; then
		shred --iterations=1 --random-source=/dev/urandom -u --zero $*
	else
		echo "Usage: secrm <files...>"
	fi
}

select-wallpaper () {
	if [ -n "$DISPLAY" ]; then
		[ -f "$1" ] && feh --bg-fill "$1" && return

		local wallpaper=""
		local hour=$(date '+%H')

		if [ $hour -ge 6 ] && [ $hour -lt 14 ]; then
			wallpaper=$(sxiv -o "$WALLPAPERS/06")
			[ -n "$wallpaper" ] && feh --bg-fill "$wallpaper"
		elif [ $hour -ge 14 ] && [ $hour -lt 20 ]; then
			wallpaper=$(sxiv -o "$WALLPAPERS/14")
			[ -n "$wallpaper" ] && feh --bg-fill "$wallpaper"
		else
			wallpaper=$(sxiv -o "$WALLPAPERS/20")
			[ -n "$wallpaper" ] && feh --bg-fill "$wallpaper"
		fi
	else
		echo "You're not running a graphical session."
	fi
}

shup () {
	[ ! -f "$1" ] && echo "Usage: shup <cmdfile>" && exit 0

	local profile="$1"
	local cmd=""

	while read -r line; do
		line="${line##*( )}"
		[ -n "$line" ] && [ ${line:0:1} != "#" ] && cmd="${cmd} ${line}"
	done < "$profile"

	eval $cmd
}

source-nvm () {
	[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
}

theme () {
	local light_themes_location="$HOME/.local/lib/python3.8/site-packages/pywal/colorschemes/light"
	local dark_themes_location="$HOME/.local/lib/python3.8/site-packages/pywal/colorschemes/dark"
	local light_themes dark_themes
	light_themes="$(ls -1 $light_themes_location | sed "s/.json//" | awk '{print "light - " $0}')"
	dark_themes="$(ls -1 $dark_themes_location | sed "s/.json//" | awk '{print "dark - " $0}')"

	local selection category name
	selection="$(echo -e  "$dark_themes" "\n$light_themes" | fzf)"
	if [ -n "$selection" ]; then
		category="$(echo "$selection" | grep -o '^\S*')"
		name="$(echo "$selection" | grep -o '\S*$')"
		[ "$category" == "dark" ] && wal --theme "$name"
		[ "$category" == "light" ] && wal --theme "$name" -l
		xrdb -merge "$HOME/.Xresources"
		xrdb -merge "$HOME/.cache/wal/colors.Xresources"
		. "$HOME/.local/bin/set-alacritty-colorscheme.sh" &> /dev/null
	fi
}

umnt () {
	# Find the directories at $MOUNT that are already used as a mount point.
	# Taken from: https://catonmat.net/set-operations-in-unix-shell
	# local mountpoint=$(comm -12 <(/bin/ls -1Ld $MOUNT/* | sort) \
	# 	<(mount | awk '{print $3}' | sort) | fzf)
	# [ -z $mountpoint ] && return

  for dir in $(/bin/ls -1Ld $MOUNT/* 2> /dev/null); do
		local source="$(findmnt --first-only --noheadings --output SOURCE $dir)"
		if [ "$source" ]; then
			local mounts="${mounts}\n$(findmnt --first-only --noheadings --output SOURCE $dir |
				awk -v dir="$dir" '{print dir " -> " $1}')"
		fi
	done

	[ "$mounts" ] &&
	local mountpoint=$(printf "$mounts" | tail -n +2 | fzf --reverse | awk '{print $1}') ||
	{ echo "No mounted volumes at $MOUNT/" && exit 1; }

	if [[ "$mountpoint" =~ vcrypt ]]; then
		veracrypt --text --dismount "$mountpoint" && echo "Unmounted '$mountpoint'."
		rmdir "$mountpoint"
	elif [ "$mountpoint" ]; then
		sudo umount "$mountpoint" && echo "Unmounted '$mountpoint'."
		rmdir "$mountpoint"
	fi
}

vcrypt-create () {
	[ -z "S1" ] || [ -z "$2" ] && \
		echo "Usage: vcrypt-create <path-to-encrypted-file> <size><K|M|G>" && \
		exit 1;

	veracrypt --text --create "$1" --volume-type="normal" --size="$2" --filesystem="exFAT" \
		--encryption="AES" --hash="SHA-512" --pim=0 --keyfiles="" --random-source="/dev/random"
}

export FZF_DEFAULT_COMMAND="fd --exclude '.git/' --hidden --type f"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --exclude '.git/' --hidden --type d"
[[ $- == *i* ]] && . "/usr/share/fzf/completion.bash" 2> /dev/null
[ -f "/usr/share/fzf/key-bindings.bash" ] && . "/usr/share/fzf/key-bindings.bash"

# encgpg: Encrypt stdin with password into a given file
# decgpg: Decrypt given file into a nvim buffer
export GPG_TTY=$(tty)
function encgpg { gpg -c -o "$1"; }
function decgpg { gpg -d "$1" | nvim -i NONE -n -; }

# (needs: pacman -S nnn)
export NNN_PLUG='a:archive;d:fzcd;e:_nvim $nnn*;f:-fzopen;k:-pskill'
e () {
	nnn -x "$@"
	export NNN_TMPFILE="$XDG_CONFIG_HOME/nnn/.lastd"

	if [ -f "$NNN_TMPFILE" ]; then
		. "$NNN_TMPFILE"
		rm -f "$NNN_TMPFILE" &> /dev/null
	fi

	[ "$TERM" = "linux" ] && set_vte_theme && clear
}
