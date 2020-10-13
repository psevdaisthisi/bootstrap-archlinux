script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

pushd "$script_path" > /dev/null

source ../misc.sh

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
			printwarn "Unknown option: '$1'. Will be ignored."
			shift
			;;
	esac
done
[ -z "$_host" ] && printerr "Missing mandatory '--host' option." && exit 1
[ -z "$_user" ] && printerr "Missing mandatory '--user' option." && exit 1


printinfo "\n"
printinfo "+ --------------------------------------------------- +"
printinfo "| Creating user directories and environment variables |"
printinfo "+ --------------------------------------------------- +"
[ "$_stepping" ] && { yesno "Continue?" || exit 1; }
mkdir "$HOME/.ssh"
mkdir -p "$HOME/.config/fontconfig"
mkdir -p "$HOME/.local/bin/go"
mkdir -p "$HOME/.local/share/xorg"
mkdir -p "$HOME/.local/share/fonts"
mkdir -p "$HOME/mount"
mkdir -p "$HOME/vol1/"{aur,sync/.resilio}
mkdir -p "$HOME/vol2/"{code,junk}
mkdir -p "$HOME/vol2/.cache/"{docker,go/{build,lib,mod},ipfs,npm,nvm,spotify}

{ echo "export HOST=\"${_host}\"";
  echo "export AUR=\"$HOME/vol1/aur\"";
  echo "export CODE=\"$HOME/vol2/code\"";
  echo "export JUNK=\"$HOME/vol2/junk\"";
  echo "export MOUNT=\"$HOME/mount\"";
  echo "export SYNC=\"$HOME/vol1/sync\"";
  echo "export WALLPAPERS=\"$HOME/vol1/sync/wallpapers\"";
  echo "export VOL1=\"$HOME/vol1\"";
  echo "export VOL2=\"$HOME/vol2\"";
  echo "export CONAN_USER_HOME=\"$HOME/vol2/.cache\"";
  echo "export GOBIN=\"$HOME/.local/bin/go\"";
  echo "export GOCACHE=\"$HOME/vol2/.cache/go/build\"";
  echo "export GOMODCACHE=\"$HOME/vol2/.cache/go/mod\"";
  echo "export GOPATH=\"$HOME/vol2/.cache/go/lib\"";
  echo "export IPFS_PATH=\"$HOME/vol2/.cache/ipfs\"";
  echo "export NPM_CONFIG_CACHE=\"$HOME/vol2/.cache/npm\"";
  echo "export NVM_DIR=\"$HOME/vol2/.cache/nvm\""; } > "$HOME/.env.sh"

{ echo "set --export HOST \"${_host}\"";
  echo "set --export AUR \"$HOME/vol1/aur\"";
  echo "set --export CODE \"$HOME/vol2/code\"";
  echo "set --export JUNK \"$HOME/vol2/junk\"";
  echo "set --export MOUNT \"$HOME/mount\"";
  echo "set --export SYNC \"$HOME/vol1/sync\"";
  echo "set --export WALLPAPERS \"$HOME/vol1/sync/wallpapers\"";
  echo "set --export VOL1 \"$HOME/vol1\"";
  echo "set --export VOL2 \"$HOME/vol2\"";
  echo "set --export CONAN_USER_HOME \"$HOME/vol2/.cache\"";
  echo "set --export GOBIN \"$HOME/.local/bin/go\"";
  echo "set --export GOCACHE \"$HOME/vol2/.cache/go/build\"";
  echo "set --export GOMODCACHE \"$HOME/vol2/.cache/go/mod\"";
  echo "set --export GOPATH \"$HOME/vol2/.cache/go/lib\"";
  echo "set --export IPFS_PATH \"$HOME/vol2/.cache/ipfs\"";
  echo "set --export NPM_CONFIG_CACHE \"$HOME/vol2/.cache/npm\"";
  echo "set --export NVM_DIR \"$HOME/vol2/.cache/nvm\""; } > "$HOME/.env.fish"

. "$HOME/.env.sh"

printinfo "\n"
printinfo "+ ------------------- +"
printinfo "| Installing dotfiles |"
printinfo "+ ------------------- +"
[ "$_stepping" ] && { yesno "Continue?" || exit 1; }
. install-dotfiles.sh --host-dir ".." --fix-permissions

printinfo "\n"
printinfo "+ ------------------------ +"
printinfo "| Installing user software |"
printinfo "+ ------------------------ +"
[ "$_stepping" ] && { yesno "Continue?" || exit 1; }
sudo usermod -aG docker ${_user}
sudo mkdir -p /etc/docker
echo -e "{\n\t\"data-root\": \"$HOME/vol2/.cache/docker\"\n}" | sudo tee /etc/docker/daemon.json

sudo curl -L 'https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip' -o JetBrainsMono.zip
unzip JetBrainsMono.zip -d "$HOME/.local/share/fonts/"
fc-cache --force

pip install --user wheel compiledb conan flashfocus grip pynvim pywal

cd "$NVM_DIR";
git clone https://github.com/nvm-sh/nvm.git .
git checkout "v0.36.0"
cd "$script_path"

. "$HOME/.bashrc"
source-nvm
nvm ls-remote --lts=erbium
nvm install --lts=erbium
nvm use default erbium

cd "$AUR"
_aur_packages=(bit@master brave-bin@master git-delta-bin@master grv@master
               mongodb-compass@master mprime-bin@master polybar@master
               postman-bin@master rslsync@master spotify@master teams@master)
for pkg in ${_aur_packages[*]}
do
	_name=${pkg%%@*}
	_tag=${pkg##*@}

	git clone https://aur.archlinux.org/"$_name".git && cd "$_name"
	git checkout "$_tag"

	[ "$_name" = "spotify" ] && \
		curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | gpg --import -

	makepkg -sirc --noconfirm --needed

	cd ..
done
cd "$script_path"

nvim +PlugInstall +qa

popd > /dev/null
