#!/bin/sh

dot_dir=$(pwd)               # dotfiles directory
bin_dir=~/.local/bin         # bin files directory
old_dots_dir=~/.dotfiles.old # old dotfiles backup directory

# list of packages that will be installed
pkgs="alacritty neofetch zsh pkgfile fzf\
      awesome-git xorg feh ly betterlockscreen dunst compfy\
      bc wget xclip xf86-input-synaptics xdotool xsel xkb-switch\
      alsa-utils pulseaudio pulseaudio-alsa sof-firmware\
      rofi flameshot\
      emacs neovim python-pip nodejs python-pynvim vscodium-bin\
      lf-bin zoxide rm-improved bc ueberzug udiskie ntfs-3g xdg-user-dirs\
      librewolf-bin firefox tor-browser\
      ttf-sourcecodepro-nerd ttf-iosevka-nerd ttf-roboto\
      brightnessctl\
      evince eog font-manager gpick gimp\
      zathura zathura-djvu zathura-pdf-mupdf\
      nextcloud-client libsecret gnome-keyring\
      exa bat sd ripgrep\
      unrar p7zip unzip zip\
      android-tools\
      texlive-core texlive-bin texlive-latexextra texlive-langextra texlive-formatsextra texlive-fontsextra\
      texlive-humanities texlive-science texlive-publishers texlive-langcyrillic texlive-langgreek"

# list of files/folders to symlink in homedir
config_files="alacritty awesome dunst flameshot lf neofetch nvim rofi zsh compfy betterlockscreenrc gtk-3.0 zathura user-dirs.dirs"

bin_files="inkscape-figures update list in pin re update-wall"
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
all         Install bin, config and misc.\n\
bin         Install binary files only.\n\
config      Install config files only.\n\
misc        Install fonts, icons and themes.\n\
packages    Install the necessary packages.\n\
help        Show this message and exit."
    exit 0
}

function install_all ()
{
    install_config
    install_misc
    install_bin
}

function install_bin ()
{
    mkdir -p ~/.local/bin
    for file in $bin_files
    do
        [ -e $bin_dir/$file ] && mv ~/.local/bin/$file $old_dots_dir/.local/bin
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
        [ -e $bin_dir/$file ] && mv $bin_dir/$file $old_dots_dir/.local/bin
        echo "Creating symlink to $file in $bin_dir"
        ln -s $dot_dir/bin/bar/$file $bin_dir/$file
    done
}

function install_config ()
{
    # move any existing dotfiles in homedir to directory, then create symlinks
    for file in $config_files
    do
        [ -e ~/.config/$file ] && mv ~/.config/$file $old_dots_dir/.config
        echo "Creating symlink to $file in home directory."
        ln -s $dot_dir/config/$file ~/.config/$file
    done

    [ -f ~/.bash_profile ] && mv ~/.bash_profile $old_dots_dir
    echo "Creating symlink to .bash_profile"
    ln -s $dot_dir/.bash_profile ~/.bash_profile
}

function install_misc ()
{
    fonts_path=~/.local/share/fonts
    icons_path=~/.local/share/icons
    themes_path=~/.local/share/themes

    [ ! -d $fonts_path ] && mkdir -p $fonts_path
    cp $dot_dir/fonts/* $fonts_path/

    [ ! -d $icons_path ] && mkdir -p $icons_path
    cp -r $dot_dir/icons/* $icons_path/

    [ ! -d $themes_path ] && mkdir -p $themes_path
    cp -r $dot_dir/themes/* $themes_path/
}

function install_packages ()
{
    if [[ ! "$EUID" = 0 ]]; then
        sudo ls /root
    fi

    # install yay
    if [[ ! -f $(which yay) ]]
    then
        cd $(mktemp -d)
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg --noconfirm -scri
    fi

    # install the necessary packages
    yay --noconfirm --needed -S $pkgs

    if [[ ! -f $(which vcp) ]]
    then
        cd $(mktemp -d)
        git clone https://github.com/none9632/VCP
        cd VCP
        make
        sudo make install
    fi
}

# create dotfiles_old in homedir
[ -d $old_dots_dir ] && rm -rf $old_dots_dir
echo "Creating $old_dots_dir for backup of any existing config files"
mkdir -p $old_dots_dir
mkdir -p $old_dots_dir/.config
mkdir -p $old_dots_dir/.local/bin
mkdir -p $old_dots_dir/.local/share/fonts

case "$1" in
    ""|all)   install_all      ;;
    bin)      install_bin      ;;
    config)   install_config   ;;
    misc)     install_misc     ;;
    packages) install_packages ;;
    help|*)   help             ;;
esac
