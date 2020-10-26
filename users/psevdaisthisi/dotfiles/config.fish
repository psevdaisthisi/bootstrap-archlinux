set fish_greeting

source "$HOME/.env.fish"
source "$XDG_CONFIG_HOME/fish/config.host.fish"

set -g __fish_git_prompt_show_informative_status 1
set -g __fish_git_prompt_hide_untrackedfiles 1
set -g __fish_git_prompt_showupstream "informative"
set -g __fish_git_prompt_char_upstream_ahead "↑"
set -g __fish_git_prompt_char_upstream_behind "↓"
set -g __fish_git_prompt_char_upstream_prefix ""
set -g __fish_git_prompt_char_cleanstate "#"
set -g __fish_git_prompt_char_conflictedstate "!"
set -g __fish_git_prompt_char_dirtystate "~"
set -g __fish_git_prompt_char_stagedstate "+"
set -g __fish_git_prompt_char_untrackedfiles "?"
set -g __fish_git_prompt_color_branch magenta
set -g __fish_git_prompt_color_dirtystate blue
set -g __fish_git_prompt_color_stagedstate yellow
set -g __fish_git_prompt_color_invalidstate red
set -g __fish_git_prompt_color_untrackedfiles $fish_color_normal
set -g __fish_git_prompt_color_cleanstate green
set -g fish_color_command blue --bold
set -g fish_color_cwd (cat ~/.cache/wal/colors | sed -n 1p) \
	--background (cat ~/.cache/wal/colors | sed -n 3p)
set -g fish_color_nnn (cat ~/.cache/wal/colors | sed -n 1p) \
	--background (cat ~/.cache/wal/colors | sed -n 5p)
set -g fish_color_error brred --bold

function fish_prompt
	if test "$ENABLE_GIT_PROMPT" = 1
		printf '%s %s %s%s%s%s ➤  ' (set_color $fish_color_cwd) (prompt_pwd) \
			(set_color $fish_color_normal) (__fish_git_prompt && echo ' ' || echo ' ') \
			(set_color $fish_color_nnn) ([ -n "$NNNLVL" ] && echo " $NNNLVL ") (set_color $fish_color_normal)
	else
		printf '%s %s %s%s%s ➤  ' (set_color $fish_color_cwd) (prompt_pwd) \
			(set_color $fish_color_nnn) ([ -n "$NNNLVL" ] && echo " $NNNLVL ") (set_color $fish_color_normal)
	end
end

function fish_right_prompt
	printf '%s%s%s' (date '+%T')
end

function enable_git_prompt
	set -U ENABLE_GIT_PROMPT 1
end
function disable_git_prompt
	set -e -U ENABLE_GIT_PROMPT
end

function fish_mode_prompt
  switch $fish_bind_mode
    case default
      set_color --background red
      set_color black
      echo ' C '
			set_color normal
			# echo ' '
    case insert
      echo ''
    case replace_one
      set_color --background green
      set_color black
      echo ' R '
			set_color normal
			# echo ' '
    case visual
      set_color --background yellow
      set_color black
      echo ' S '
			set_color normal
			# echo ' '
    case '*'
      set_color --background blue
      set_color black
      echo ' ? '
			set_color normal
			# echo ' '
  end
end

fish_vi_key_bindings

set --export EDITOR nvim
set --export LESSCHARSET UTF-8

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


function clear-cache --description "Clear PageCache"
	sync && echo 1 | sudo tee /proc/sys/vm/drop_caches &> /dev/null &&
		echo "System cache was cleared."
end

function clear-shada --description "Clear neovim persistent history"
	rm -f ~/.local/share/nvim/shada/*.shada
end

function clear-clipboard --description "Clear X11 clip areas"
	xclip -selection clipboard -in /dev/null
	xclip -selection primary -in /dev/null
	xclip -selection secondary -in /dev/null
end

function clipit --description "Copy the content of a file to the clipboard"
	if [ -f "$argv[1]" ]
		set --local mimetype (file --brief --mime-type "$argv[1]")
		[ "$mimetype" = "text/plain" ] && xclip -selection clipboard -in "$argv[1]"
		[ "$mimetype" != "text/plain" ] && xclip -selection clipboard -t "$mimetype" -in "$argv[1]"
	end
end

function config-hids --description "Set keyboard layout and pointer speed for X11"
	bash -l -c "config-hids"
end

function energypolicy --description "Enables an energy policy"
	bash -l -c "energypolicy $argv"
end

function qemu-create --description "Create QEMU qcow2 disk"
	bash -l -c "qemu-create $argv"
end

function qemu-snapshot --description "Create a snapshot of QEMU disk"
	bash -l -c "qemu-snapshot $argv"
end

function qemu-start --description "Starts a QEMU VM"
	bash -l -c "qemu-start $argv"
end

function qemu-start-win --description "Starts a QEMU Windows VM"
	bash -l -c "qemu-start-win $argv"
end

function mkcd --description "Make directory and cd into it"
	mkdir "$argv[1]"
	cd "$argv[1]"
end

function mnt --description "Mount a device the users group can write to"
	bash -l -c "mnt $argv"
end

function mnt-gocrypt --description "Mount a folder encrypted by gocryptfs"
	bash -l -c "mnt-gocrypt $argv"
end

function mnt-vcrypt --description "Mount a Veracrypt file"
	bash -l -c "mnt-vcrypt $argv"
end

function random-wallpaper --description "Changes the wallpaper randomly"
	bash -l -c "random-wallpaper"
end

function screenshot --description "Take a screenshot"
	bash -l -c "screenshot"
end

function secrm --description "Delete files securely"
	bash -l -c "secrm $argv"
end

function select-wallpaper --description "Select the wallpapers from a slideshow"
	bash -l -c "select-wallpaper"
end

function shup --description "Evaluate Bash commands out of a file"
	bash -l -c "shup $argv"
end

function theme --description "Set a colorscheme from pywall"
	bash -l -c "theme"
end

function umnt --description "Unmount a partition, gofscrypt folder or Veracrypt file"
	bash -l -c "umnt $argv"
end

function vcrypt-create --description "Create a password-encrypt Veracrypt file"
	bash -l -c "vcrypt-create $argv"
end


set --export FZF_DEFAULT_COMMAND "fd --exclude '.git/'  --hidden --type f"
set --export FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set --export FZF_ALT_C_COMMAND "fd --exclude '.git/' --hidden --type d"
if test -f /usr/share/fish/functions/fzf_key_bindings.fish
	source /usr/share/fish/functions/fzf_key_bindings.fish
end
fzf_key_bindings

set --export GPG_TTY (tty)
function encgpg --description "Encrypt stdin with password into a given file"
	gpg -c -o "$argv[1]"
end
function decgpg --description "Decrypt given file into a nvim buffer"
	gpg -d "$argv[1]" | nvim -i NONE -n -;
end

set --export NNN_PLUG 'a:archive;d:fzcd;e:_nvim $nnn*;f:-fzopen;k:-pskill'
function e --description "Starts nnn in the current directory"
	env SHELL="/usr/bin/fish" nnn -x $argv
	set --export NNN_TMPFILE $XDG_CONFIG_HOME/nnn/.lastd

	if test -e $NNN_TMPFILE
		source $NNN_TMPFILE
		rm $NNN_TMPFILE
	end
end
