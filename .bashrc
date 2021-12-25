[[ $- != *i* ]] && return

prefix="λ"
green="\033[38;5;2m\033[1;1m"
blue="\033[34;1m"
bblack="\033[38;5;8m"
borange="\033[38;5;11m\033[1;1m"
bcyan="\033[38;5;14m"
reset="\033[0m"

PS1="\
${bblack}┌[${reset}\
${green}\w${reset}\
${bblack}]─[${reset}\
${blue}\u${reset}\
${bblack}]─[${reset}\
${borange}\h${reset}\
${bblack}]${reset}\n\
${bblack}└>${reset} \
${bcyan}${prefix}${reset} "

alias stcpu="stress -c 8"
alias stmem="stress -vm 2 --vm-bytes"

alias pacman="sudo pacman"
alias pacsyu="sudo pacman -Syu"
alias yaysyu="yay -Syu"

alias ls="exa -la --color=always --group-directories-first"
alias cat="bat"
alias rm="rm -r"
alias cp="cp -r"

echo ""
neofetch
