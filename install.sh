#!/bin/sh

dot_dir=$(pwd)               # dotfiles directory
bin_dir=~/.local/bin         # bin files directory
old_dots_dir=~/.dotfiles.old # old dotfiles backup directory

# list of packages that will be installed
pkgs="alacritty neofetch zsh pkgfile fzf \
      awesome-git xorg feh ly betterlockscreen\
      bc wget xclip xf86-input-synaptics xdotool xsel xkb-switch\
      rofi flameshot\
      emacs neovim\
      lf-bin zoxide rm-improved bc ueberzug udiskie\
      librewolf-bin firefox tor-browser\
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
config_files="alacritty awesome dunst flameshot lf neofetch nvim rofi zsh picom betterlockscreenrc gtk-3.0"

bin_files="inkscape-figures update list in pin re"
bar_c_files="cpu ram"
bar_bin_files="$bar_c_files updates"

function help
{
    echo -e "\
Usage: install.sh [COMMAND]\n\
\n\
By default installs config.
\n\
Commands:\n\
all         Install all.\n\
bin         Install binary files only.\n\
config      Install config files only.\n\
misc        Install fonts, icons and themes.\n\
packages    Install the necessary packages.\n\
system      Install personal system configuration.\n\
help        Show this message and exit."
    exit 0
}

function install_all ()
{
    install_packages
    install_system
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
        ln -s $dot_dir/.config/$file ~/.config/$file
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

    echo -n "Fonts installation..."
    [ ! -d $fonts_path ] && mkdir -p $fonts_path
    cp $dot_dir/fonts/* $fonts_path/
    echo "done"

    echo -n "Icons installation..."
    [ ! -d $icons_path ] && mkdir -p $icons_path
    cp -r $dot_dir/icons/* $icons_path/
    echo "done"

    echo -n "Themes installation..."
    [ ! -d $themes_path ] && mkdir -p $themes_path
    cp -r $dot_dir/themes/* $themes_path/
    echo "done"
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

function install_system ()
{
    if [[ ! "$EUID" = 0 ]]; then
        sudo ls /root
    fi

    # setting display manager
    sudo systemctl enable ly

    # betterlockscreen
    echo "[Unit]
Description = Lock screen when going to sleep/suspend
Before=sleep.target
Before=suspend.target

[Service]
User=%i
Type=simple
Environment=DISPLAY=:0
ExecStart=/usr/bin/betterlockscreen --lock
TimeoutSec=infinity
ExecStartPost=/usr/bin/sleep 1
ExecStartPre=/usr/bin/xkb-switch -s us

[Install]
WantedBy=sleep.target
WantedBy=suspend.target" | sudo tee /etc/systemd/system/betterlockscreen@.service
    sudo systemctl enable betterlockscreen@$(whoami).service

    # gnome-keyring
    echo "auth       optional     pam_gnome_keyring.so
session    optional     pam_gnome_keyring.so auto_start" | sudo tee -a /etc/pam.d/login

    # zsh
    if [ "$(ls /var/cache/pkgfile)" == "" ]
    then
        sudo pkgfile --update
    fi

    # vim-plug
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
           https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

    # git configuration
    git config --global user.email "none9632@protonmail.com"
    git config --global user.name "none9632"

    # Touchpad configuration
    mkdir -p /etc/X11/xorg.conf.d
    echo "Section \"InputClass\"
    Identifier \"devname\"
    Driver \"libinput\"
    MatchIsTouchpad \"on\"
        Option \"Tapping\" \"on\"
        Option \"HorizontalScrolling\" \"on\"
        Option \"TappingButtonMap\" \"lrm\"
EndSection" | sudo tee /etc/X11/xorg.conf.d/40-libinput.conf

    # Touchpad fix for my laptop (https://bbs.archlinux.org/viewtopic.php?id=263407)
    echo "[Unit]
Description=I hope hope hope this works
Conflicts=getty@tty1.service
After=systemd-user-sessions.service getty@tty1.service systemd-logind.service

[Service]
ExecStart=/usr/bin/bash -c '\
  /usr/bin/modprobe -r i2c_hid; \
  /usr/bin/modprobe i2c_hid'

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/touchpadfix.service
    systemctl enable touchpadfix.service

    # sudo configuration
    echo "$name myPC= NOPASSWD: /usr/bin/yay -Syy,/usr/bin/pacman -Sql" |
        sudo tee -a /etc/sudoers

    # pacman configuration
    sudo sed -i -e 's/#Color/Color/g' /etc/pacman.conf
    sudo sed -i -e 's/#VerbosePkgLists/VerbosePkgLists/g' /etc/pacman.conf
    sudo sed -i -e 's/#ParallelDownloads = 5/ParallelDownloads = 5/g' /etc/pacman.conf

    # changed default browser
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

    # automatically installs browser extensions
    librewolf_dir=$HOME/.librewolf/$(ls $HOME/.librewolf | grep -E *-release)/extensions
    firefox_dir=$HOME/.mozilla/firefox/$(ls $HOME/.mozilla/firefox | grep -E *-release)/extensions
    links="https://addons.mozilla.org/firefox/downloads/file/3961087/ublock_origin-1.43.0.xpi\
           https://addons.mozilla.org/firefox/downloads/file/3965972/vimium_c-1.98.3.xpi\
           https://addons.mozilla.org/firefox/downloads/file/3910598/canvasblocker-1.8.xpi\
           https://addons.mozilla.org/firefox/downloads/file/3902154/decentraleyes-2.0.17.xpi\
           https://addons.mozilla.org/firefox/downloads/file/3971429/cookie_autodelete-3.8.1.xpi\
           https://addons.mozilla.org/firefox/downloads/file/3965730/i_dont_care_about_cookies-3.4.1.xpi\
           https://addons.mozilla.org/firefox/downloads/file/3872283/privacy_badger17-2021.11.23.1.xpi\
           https://addons.mozilla.org/firefox/downloads/file/3968598/duckduckgo_for_firefox-2022.6.27.xpi\
           https://addons.mozilla.org/firefox/downloads/file/3954910/noscript-11.4.6.xpi\
           https://addons.mozilla.org/firefox/downloads/file/3790944/dont_track_me_google1-4.26.xpi\
           https://addons.mozilla.org/firefox/downloads/file/3980848/clearurls-1.25.0.xpi"

    mkdir -p $librewolf_dir $firefox_dir

    for link in $links
    do
        dir=$(mktemp -d)
        file=$(echo $link | awk 'BEGIN{FS="/"} {print $NF}')

        echo -n "Installing $file..."
        cd $dir
        wget -q $link
        unzip -q ./$file -d $dir

        if [ -e $dir/mozilla-recommendation.json ]
        then
            addon_id=$(egrep -o 'addon_id":"[^"]+' ./mozilla-recommendation.json | awk 'BEGIN{FS="\""} {print $NF}')
        else
            addon_id=$(egrep -o 'id":[\ ]+"[^"]+' ./manifest.json | awk 'BEGIN{FS="\""} {print $NF}')
        fi
        if [ "$addon_id" != "" ]
        then
            cp $dir/$file $librewolf_dir/${addon_id}.xpi
            cp $dir/$file $firefox_dir/${addon_id}.xpi
            echo "done"
        else
            echo "error"
        fi
    done
}

# create dotfiles_old in homedir
[ -d $old_dots_dir ] && rm -rf $old_dots_dir
echo "Creating $old_dots_dir for backup of any existing config files"
mkdir -p $old_dots_dir
mkdir -p $old_dots_dir/.config
mkdir -p $old_dots_dir/.local/bin
mkdir -p $old_dots_dir/.local/share/fonts

case "$1" in
    ""|config) install_config   ;;
    all)       install_all      ;;
    bin)       install_bin      ;;
    misc)      install_misc     ;;
    system)    install_system   ;;
    packages)  install_packages ;;
    help|*)    help             ;;
esac
