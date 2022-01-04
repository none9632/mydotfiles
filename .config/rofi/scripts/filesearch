#!/bin/sh

pwd=$1
ls_command="exa -a --color=never --group-directories-first $pwd"
rofi_command="rofi -scroll-method 1\
                   -i
                   -theme $HOME/.config/rofi/themes/menu/filesearch.rasi"
list=$(LC_COLLATE=C ls -A --group-directories-first $pwd)

function print_icon()
{
    if [ -L $pwd/$1 ]; then
        echo "ln_file"
    elif [ -d $pwd/$1 ]; then
        echo "dir"
    elif [ -x $pwd/$1 ]; then
        echo "exe_file"
    else
        case "$1" in
            Makefile)         echo "makefile"      ;;
            makefile)         echo "makefile"      ;;
            Dockerfile)       echo "docker1"       ;;
            dockerfile)       echo "docker1"       ;;
            README)           echo "markdown"      ;;
            CMakeLists.txt)   echo "cmake"         ;;
            TAGS)             echo "tags"          ;;
            TODO)             echo "todo2"         ;;
            LICENSE)          echo "license2"      ;;
            .gitignore)       echo "git"           ;;
            .vimrc)           echo "vim"           ;;
            .viminfo)         echo "vim"           ;;
            .zshrc)           echo "exe_file"      ;;
            .zprofile)        echo "exe_file"      ;;
            .zshenv)          echo "exe_file"      ;;
            .bashrc)          echo "exe_file"      ;;
            .bash_logout)     echo "exe_file"      ;;
            .bash_profile)    echo "exe_file"      ;;
            .profile)         echo "exe_file"      ;;
            .xinitrc)         echo "exe_file"      ;;
            .xprofile)        echo "exe_file"      ;;
            *.asm)            echo "assembly"      ;;
            *.b)              echo "brainfuck"     ;;
            *.c)              echo "c"             ;;
            *.cc)             echo "c"             ;;
            *.clj)            echo "clojure"       ;;
            *.cljc)           echo "clojure"       ;;
            *.cmake)          echo "cmake"         ;;
            *.conf)           echo "settings_file" ;;
            *.coffee)         echo "coffee"        ;;
            *.cpp)            echo "cpp"           ;;
            *.cs)             echo "csharp"        ;;
            *.css)            echo "css"           ;;
            *.d)              echo "d"             ;;
            *.dart)           echo "dart-plain"    ;;
            *.db)             echo "database"      ;;
            *.djvu)           echo "book"          ;;
            *.doc)            echo "word"          ;;
            *.dockerfile)     echo "docker1"       ;;
            *.docx)           echo "word"          ;;
            *.eex)            echo "elixir"        ;;
            *.el)             echo "elisp"         ;;
            *.elc)            echo "elisp"         ;;
            *.elm)            echo "elm"           ;;
            *.erl)            echo "erlang"        ;;
            *.ex)             echo "elixir"        ;;
            *.exs)            echo "elixir"        ;;
            *.fs)             echo "fsharp"        ;;
            *.go)             echo "go"            ;;
            *.h)              echo "h"             ;;
            *.hh)             echo "hpp"           ;;
            *.hpp)            echo "hpp"           ;;
            *.hs)             echo "haskell"       ;;
            *.html)           echo "html"          ;;
            *.ino)            echo "arduino"       ;;
            *.iso)            echo "iso"           ;;
            *.java)           echo "java"          ;;
            *.jl)             echo "julia"         ;;
            *.js)             echo "javascript"    ;;
            *.jsx)            echo "jsx"           ;;
            *.json)           echo "json"          ;;
            *.key)            echo "key"           ;;
            *.kt)             echo "kotlin"        ;;
            *.kts)            echo "kotlin"        ;;
            *.less)           echo "css"           ;;
            *.log)            echo "log_file"      ;;
            *.lua)            echo "lua"           ;;
            *.md)             echo "markdown"      ;;
            *.nasm)           echo "assembly"      ;;
            *.ods)            echo "table_file"    ;;
            *.org)            echo "org-mode"      ;;
            *.pdf)            echo "pdf_file"      ;;
            *.pem)            echo "key"           ;;
            *.php)            echo "php"           ;;
            *.pl)             echo "perl"          ;;
            *.ppt)            echo "powerpoint"    ;;
            *.pptx)           echo "powerpoint"    ;;
            *.py)             echo "python"        ;;
            *.rb)             echo "ruby"          ;;
            *.rs)             echo "rust"          ;;
            *.S)              echo "assembly"      ;;
            *.s)              echo "assembly"      ;;
            *.scala)          echo "scala"         ;;
            *.sql)            echo "database"      ;;
            *.sqlite)         echo "database"      ;;
            *.swift)          echo "swift"         ;;
            *.tex)            echo "tex"           ;;
            *.torrent)        echo "torrent"       ;;
            *.ts)             echo "typescript"    ;;
            *.vim)            echo "vim"           ;;
            *.xls)            echo "excel"         ;;
            *.xlsx)           echo "excel"         ;;
            *.xml)            echo "xml"           ;;
            *.yml)            echo "yaml"          ;;
            *.ttf)            echo "font"          ;;
            *.ttc)            echo "font"          ;;
            *.otf)            echo "font"          ;;
            *.woff)           echo "font"          ;;
            *.o)              echo "bin_file"      ;;
            *.obj)            echo "bin_file"      ;;
            *.exe)            echo "bin_file"      ;;
            *.bin)            echo "bin_file"      ;;
            *.elf)            echo "bin_file"      ;;
            *.cmd)            echo "exe_file"      ;;
            *.ps1)            echo "exe_file"      ;;
            *.sh)             echo "exe_file"      ;;
            *.bash)           echo "exe_file"      ;;
            *.zsh)            echo "exe_file"      ;;
            *.fish)           echo "exe_file"      ;;
            *.mp4)            echo "video_file"    ;;
            *.webm)           echo "video_file"    ;;
            *.mkv)            echo "video_file"    ;;
            *.flv)            echo "video_file"    ;;
            *.vob)            echo "video_file"    ;;
            *.ogv)            echo "video_file"    ;;
            *.ogm)            echo "video_file"    ;;
            *.gifv)           echo "video_file"    ;;
            *.mpg)            echo "video_file"    ;;
            *.mpeg)           echo "video_file"    ;;
            *.mp4v)           echo "video_file"    ;;
            *.wmv)            echo "video_file"    ;;
            *.qt)             echo "video_file"    ;;
            *.yuv)            echo "video_file"    ;;
            *.rm)             echo "video_file"    ;;
            *.rmvb)           echo "video_file"    ;;
            *.viv)            echo "video_file"    ;;
            *.asf)            echo "video_file"    ;;
            *.m4v)            echo "video_file"    ;;
            *.avi)            echo "video_file"    ;;
            *.mov)            echo "video_file"    ;;
            *.m2v)            echo "video_file"    ;;
            *.nuv)            echo "video_file"    ;;
            *.flc)            echo "video_file"    ;;
            *.fli)            echo "video_file"    ;;
            *.gl)             echo "video_file"    ;;
            *.ogx)            echo "video_file"    ;;
            *.mp3)            echo "audio_file"    ;;
            *.aac)            echo "audio_file"    ;;
            *.m4a)            echo "audio_file"    ;;
            *.oga)            echo "audio_file"    ;;
            *.spx)            echo "audio_file"    ;;
            *.au)             echo "audio_file"    ;;
            *.wav)            echo "audio_file"    ;;
            *.opus)           echo "audio_file"    ;;
            *.ra)             echo "audio_file"    ;;
            *.flac)           echo "audio_file"    ;;
            *.mid)            echo "audio_file"    ;;
            *.midi)           echo "audio_file"    ;;
            *.mka)            echo "audio_file"    ;;
            *.mpc)            echo "audio_file"    ;;
            *.xspf)           echo "audio_file"    ;;
            *.jpg)            echo "img_file"      ;;
            *.jpeg)           echo "img_file"      ;;
            *.mjpg)           echo "img_file"      ;;
            *.mjpeg)          echo "img_file"      ;;
            *.ico)            echo "img_file"      ;;
            *.gif)            echo "img_file"      ;;
            *.bmp)            echo "img_file"      ;;
            *.pbm)            echo "img_file"      ;;
            *.pgm)            echo "img_file"      ;;
            *.ppm)            echo "img_file"      ;;
            *.tga)            echo "img_file"      ;;
            *.xbm)            echo "img_file"      ;;
            *.xpm)            echo "img_file"      ;;
            *.tif)            echo "img_file"      ;;
            *.tiff)           echo "img_file"      ;;
            *.png)            echo "img_file"      ;;
            *.svg)            echo "img_file"      ;;
            *.svgz)           echo "img_file"      ;;
            *.mng)            echo "img_file"      ;;
            *.pcx)            echo "img_file"      ;;
            *.xcf)            echo "img_file"      ;;
            *.xwd)            echo "img_file"      ;;
            *.cgm)            echo "img_file"      ;;
            *.emf)            echo "img_file"      ;;
            *.tar)            echo "zip_file"      ;;
            *.tgz)            echo "zip_file"      ;;
            *.arc)            echo "zip_file"      ;;
            *.arj)            echo "zip_file"      ;;
            *.taz)            echo "zip_file"      ;;
            *.lha)            echo "zip_file"      ;;
            *.lz4)            echo "zip_file"      ;;
            *.lzh)            echo "zip_file"      ;;
            *.lzma)           echo "zip_file"      ;;
            *.tlz)            echo "zip_file"      ;;
            *.txz)            echo "zip_file"      ;;
            *.tzo)            echo "zip_file"      ;;
            *.t7z)            echo "zip_file"      ;;
            *.zip)            echo "zip_file"      ;;
            *.z)              echo "zip_file"      ;;
            *.dz)             echo "zip_file"      ;;
            *.gz)             echo "zip_file"      ;;
            *.lrz)            echo "zip_file"      ;;
            *.lz)             echo "zip_file"      ;;
            *.lzo)            echo "zip_file"      ;;
            *.xz)             echo "zip_file"      ;;
            *.zst)            echo "zip_file"      ;;
            *.tzst)           echo "zip_file"      ;;
            *.bz2)            echo "zip_file"      ;;
            *.bz)             echo "zip_file"      ;;
            *.tbz)            echo "zip_file"      ;;
            *.tbz2)           echo "zip_file"      ;;
            *.tz)             echo "zip_file"      ;;
            *.deb)            echo "zip_file"      ;;
            *.rpm)            echo "zip_file"      ;;
            *.jar)            echo "zip_file"      ;;
            *.war)            echo "zip_file"      ;;
            *.ear)            echo "zip_file"      ;;
            *.sar)            echo "zip_file"      ;;
            *.rar)            echo "zip_file"      ;;
            *.alz)            echo "zip_file"      ;;
            *.ace)            echo "zip_file"      ;;
            *.zoo)            echo "zip_file"      ;;
            *.cpio)           echo "zip_file"      ;;
            *.7z)             echo "zip_file"      ;;
            *.rz)             echo "zip_file"      ;;
            *.cab)            echo "zip_file"      ;;
            *.wim)            echo "zip_file"      ;;
            *.swm)            echo "zip_file"      ;;
            *.dwm)            echo "zip_file"      ;;
            *.esd)            echo "zip_file"      ;;
            *)                echo "text_file"     ;;
        esac
    fi
}

function options()
{
    for file in $list
    do
        icon=$(print_icon "$file")
        echo -en "$file\0icon\x1f$icon\n"
    done
}

chosen="$(options | $rofi_command -p " Search " -dmenu)"
if [ "$chosen" != "" ]
then
    echo "$pwd/$chosen"
else
    echo "."
fi
