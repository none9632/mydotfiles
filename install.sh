dot_dir=$(pwd)          # dotfiles directory
bin_dir=~/.local/bin    # bin files directory
bak_dir=~/.dotfiles.bak # old dotfiles backup directory

# list of the build packages
build_pkgs="base-devel git gcc make cmake"

# list of packages that will be installed
pkgs="alacritty neofetch rofi flameshot scrot xdotool picom-git"

# list of files/folders to symlink in homedir
config_files="alacritty neofetch picom rofi"

rofi_bin_files="appslauncher appsmenu errormsg filesearch input longinput powermenu screenshot"

error()
{
    printf "error: %s\n" "$1" >&2
    exit 1
}

if [[ ! "$EUID" = 0 ]]; then
    sudo ls /root
fi

# install the necessary build packages
sudo pacman --noconfirm --needed -Sy $build_pkgs

# install yay
if [[ ! -f /usr/bin/yay ]]
then
    cd $(mktemp -d)
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg --noconfirm -scri
fi

# install the necessary packages
yay --noconfirm --needed -Sy $pkgs

# create dotfiles_old in homedir
[ -d $bak_dir ] && rm -rf $bak_dir
echo "Creating $bak_dir for backup of any existing config files"
mkdir -p $bak_dir
mkdir -p $bak_dir/.config

# move any existing dotfiles in homedir to  directory, then create symlinks
for file in $config_files
do
    if [ -d ~/.config/$file ]
    then
        echo "Moving $file from ~/.config to $bak_dir/.config"
        mv ~/.config/$file $bak_dir/.config 2> /dev/null
    fi
done

for file in $config_files
do
    echo "Creating symlink to $file in home directory."
    ln -s $dot_dir/.config/$file ~/.config/$file
done

for file in $rofi_bin_files
do
    if [ ! -f $bin_dir/$file ]
    then
        echo "Creating symlink to $file in $bin_dir"
        ln -s $dot_dir/.config/rofi/scripts/$file.sh $bin_dir/$file
    fi
done
