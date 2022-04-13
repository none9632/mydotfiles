#!/bin/sh

dot_dir=$(pwd)               # dotfiles directory
bin_dir=~/.local/bin         # bin files directory
old_dots_dir=~/.dotfiles.old # old dotfiles backup directory

# list of the build packages
build_pkgs="base-devel git gcc make cmake"
# list of packages that will be installed
pkgs="alacritty neofetch rofi flameshot lf-bin scrot xdotool picom zoxide brightnessctl alsa-utils dunst evince font-manager"

# list of files/folders to symlink in homedir
config_files="alacritty awesome dunst flameshot lf neofetch nvim rofi zsh picom"

bin_files="inkscape-figures update list in pin re mylf"
bar_c_files="cpu ram"
bar_bin_files="$bar_c_files updates"

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
font        Install font only.\n\
packages    Install only the necessary packages.\n\
help        Show this message and exit."
    exit 0
}

function install_all ()
{
    install_pkgs
    install_config
    install_font
    install_bin
}

function install_bin ()
{
    for file in $bin_files
    do
        if [ -e $bin_dir/$file ]
        then
            echo "Moving $file from ~/.local/bin/ to $old_dots_dir/.local/bin"
            mv ~/.local/bin/$file $old_dots_dir/.local/bin
        fi
    done
    for file in $bin_files
    do
        echo "Creating symlink to $file in $bin_dir"
        ln -s $dot_dir/bin/$file $bin_dir/$file
    done

    for file in $bar_c_files
    do
        echo "Compilation $file file"
        gcc -Wall -O3 $dot_dir/bin/bar/$file.c -o $dot_dir/bin/bar/$file
    done
    for file in $bar_bin_files
    do
        if [ -e $bin_dir/$file ]
        then
            echo "Moving $file from ~/.local/bin/ to $old_dots_dir/.local/bin"
            mv ~/.local/bin/$file $old_dots_dir/.local/bin
        fi
    done
    for file in $bar_bin_files
    do
        echo "Creating symlink to $file in $bin_dir"
        ln -s $dot_dir/bin/bar/$file $bin_dir/$file
    done
}

function install_config ()
{
    # move any existing dotfiles in homedir to directory, then create symlinks
    for file in $config_files
    do
        if [ -d ~/.config/$file ]
        then
            echo "Moving $file from ~/.config to $old_dots_dir/.config"
            mv ~/.config/$file $old_dots_dir/.config
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

function install_font ()
{
    font_path=~/.local/share/fonts
    font_file=MyFont.ttf

    [ -f $font_path/$font_file ] && mv $font_path/$font_file $old_dots_dir/.local/share/fonts
    echo "Font installation"
    cp $dot_dir/font/$font_file $font_path
}

function install_pkgs ()
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

# create dotfiles_old in homedir
[ -d $old_dots_dir ] && rm -rf $old_dots_dir
echo "Creating $old_dots_dir for backup of any existing config files"
mkdir -p $old_dots_dir
mkdir -p $old_dots_dir/.config
mkdir -p $old_dots_dir/.local/bin
mkdir -p $old_dots_dir/.local/share/fonts

case "$1" in
    ""|all)   install_all    ;;
    bin)      install_bin    ;;
    config)   install_config ;;
    font)     install_font   ;;
    packages) install_pkgs   ;;
    help|*)   help           ;;
esac
