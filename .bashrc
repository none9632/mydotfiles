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

alias ls='ls --color=auto'

echo ""
neofetch
