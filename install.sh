#!/bin/sh

dot_dir=$(pwd)               # dotfiles directory
bin_dir=~/.local/bin         # bin files directory
old_dots_dir=~/.dotfiles.old # old dotfiles backup directory

# list of packages that will be installed
pkgs="alacritty neofetch zsh pkgfile fzf xdotool xsel xkb-switch\
      awesome-git xorg feh ly\
      rofi flameshot\
      emacs neovim\
      lf-bin zoxide rm-improved bc ueberzug udiskie\
      librewolf-bin firefox\
      nerd-fonts-source-code-pro ttf-iosevka-nerd ttf-roboto\
      picom-animations-git\
      brightnessctl\
      alsa-utils\
      dunst\
      evince eog\
      font-manager\
      nextcloud-client libsecret gnome-keyring\
      gpick\
      exa bat\
      unrar p7zip unzip\
      texlive-core texlive-bin texlive-latexextra texlive-langextra texlive-formatsextra texlive-fontsextra\
      texlive-humanities texlive-science texlive-publishers texlive-langcyrillic texlive-langgreek"

# list of files/folders to symlink in homedir
config_files="alacritty awesome dunst flameshot lf neofetch nvim rofi zsh picom"

bin_files="inkscape-figures update list in pin re"
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
        [ -d ~/.config/$file ] && mv ~/.config/$file $old_dots_dir/.config
        echo "Creating symlink to $file in home directory."
        ln -s $dot_dir/.config/$file ~/.config/$file
    done

    [ -f ~/.bash_profile ] && mv ~/.bash_profile $old_dots_dir
    echo "Creating symlink to .bash_profile"
    ln -s $dot_dir/.bash_profile ~/.bash_profile

    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
}

function install_font ()
{
    font_path=~/.local/share/fonts
    font_files="MyFont.ttf Feather.ttf"

    echo "Font installation"
    [ ! -d $font_path ] && mkdir $font_path

    for file in $font_files
    do
        [ -f $font_path/$file ] && mv $font_path/$file $old_dots_dir/.local/share/fonts
        cp $dot_dir/font/$file $font_path/$file
    done
}

function install_pkgs ()
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

    # Setting display manager
    sudo systemctl enable ly
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

mimeapps_dir="$HOME/.local/share/applications"
mimeapps_file="$mimeapps_dir/mimeapps.list"
if [[ ! -s $mimeapps_file ]]
then
    mkdir -p $mimeapps_dir
    touch $mimeapps_file
    echo "[Default Applications]" > $mimeapps_file
    echo "x-scheme-handler/http=librewolf.desktop" >> $mimeapps_file
    echo "x-scheme-handler/https=librewolf.desktop" >> $mimeapps_file
fi
