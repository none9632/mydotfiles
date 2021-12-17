dir=$(pwd)                              # dotfiles directory
bakdir=~/.dotfiles.bak                  # old dotfiles backup directory
packages="alacritty neofetch rofi maim" # list of packages that will be installed
config_files="alacritty neofetch"       # list of files/folders to symlink in homedir

error()
{
    printf "error: %s\n" "$1" >&2
    exit 1
}

if [[ ! "$EUID" = 0 ]]; then
    sudo ls /root
fi

# install yay
if [[ ! -f /usr/bin/yay ]]
then
    sudo pacman --noconfirm --needed -S git base-devel
    cd $(mktemp -d)
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg --noconfirm -scri
fi

# install the necessary packages
yay --noconfirm --needed -Sy $packages

# create dotfiles_old in homedir
[ -d $bakdir ] && rm -rf $bakdir
echo "Creating $bakdir for backup of any existing config files"
mkdir -p $bakdir
mkdir -p $bakdir/.config

# move any existing dotfiles in homedir to  directory, then create symlinks
for file in $config_files
do
    if [ -d ~/.config/$file ]
    then
        echo "Moving $file from ~/.config to $bakdir/.config"
        mv ~/.config/$file $bakdir/.config 2> /dev/null
    fi
done

for file in $config_files
do
    echo "Creating symlink to $file in home directory."
    ln -s $dir/.config/$file ~/.config/$file
done
