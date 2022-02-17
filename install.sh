#!/bin/sh

dot_dir=$(pwd)               # dotfiles directory
bin_dir=~/.local/bin         # bin files directory
old_dots_dir=~/.dotfiles.old # old dotfiles backup directory

# list of the build packages
build_pkgs="base-devel git gcc make cmake"
# list of packages that will be installed
pkgs="alacritty neofetch rofi flameshot lf-bin scrot xdotool picom-git zoxide brightnessctl alsa-utils"

# list of files/folders to symlink in homedir
config_files="alacritty flameshot lf neofetch nvim rofi zathura zsh polybar"

bin_files="inkscape-figures update list in pin re"

function help
{
    echo -e "\
Usage: install.sh [COMMAND]\n\
\n\
By default installs all.
\n\
Commands:\n\
all         Install all.\n\
bin         Install binary files only.\n\
config      Install config files only.\n\
pcakages    Install only the necessary packages.\n\
help        Show this message and exit."
    exit 0
}

function install_all ()
{
    install_packages
    install_config
    install_bin
}

function install_bin ()
{
    for file in $bin_files
    do
        if [ ! -f $bin_dir/$file ]
        then
            echo "Creating symlink to $file in $bin_dir"
            ln -s $dot_dir/bin/$file $bin_dir/$file
        fi
    done
}

function install_config ()
{
    # create dotfiles_old in homedir
    [ -d $old_dots_dir ] && rm -rf $old_dots_dir
    echo "Creating $old_dots_dir for backup of any existing config files"
    mkdir -p $old_dots_dir
    mkdir -p $old_dots_dir/.config

    # move any existing dotfiles in homedir to directory, then create symlinks
    for file in $config_files
    do
        if [ -d ~/.config/$file ]
        then
            echo "Moving $file from ~/.config to $old_dots_dir/.config"
            mv ~/.config/$file $old_dots_dir/.config 2> /dev/null
        fi
    done
    for file in $config_files
    do
        echo "Creating symlink to $file in home directory."
        ln -s $dot_dir/.config/$file ~/.config/$file
    done

    [ -f ~/.bash_profile ] && mv ~/.bash_profile $old_dots_dir
    echo "Creating symlink to .bash_profile"
    ln -s $dot_dir/.bash_profile ~/.bash_profile
}

function install_packages ()
{
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
    yay --noconfirm --needed -S $pkgs
}

case "$1" in
    "")       install_all      ;;
    all)      install_all      ;;
    bin)      install_bin      ;;
    packages) install_packages ;;
    config)   install_config   ;;
    help|*)   help             ;;
esac
