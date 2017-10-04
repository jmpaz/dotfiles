# variables
export DOTS="$HOME/.dotfiles" 
export VMDIR="$HOME/.dotfiles/host-vm-ubuntu"
export CBDIR="$HOME/.dotfiles/host-cb-xfce"

# personal
alias la="ls -A"
alias cls="colorls -sd"
alias cla="colorls -sd -A"
alias todo="todotxt-machine"
alias fehs="feh -. -S filename" # scale down to window and sort by filename

# config
alias dots="cd $DOTS"
alias zshconf="vim ~/.zshrc"
alias alconf="vim ~/.util/aliases.sh"
alias vmconf="vim $VMDIR/util/host.sh"
alias cbconf="vim $CBDIR/util/host.sh"
alias xrconf="vim ~/.Xresources"
alias i3conf="vim ~/.config/i3/config"
alias i3conf-vm="vim $VMDIR/config/i3/config"
alias i3conf-cb="vim $CBDIR/config/i3/config"
alias polyconf="vim ~/.config/polybar/config"
alias vimconf="vim ~/.vimrc"
alias termconf="vim ~/.config/terminator/config"
alias compconf="vim ~/.compton.conf"
alias todoconf="vim ~/.todotxt-machinerc"
alias todoref="todoconf && todotxt-machine"
alias walscheme="wal -n -ti"
alias fehwal="feh --bg-scale \"\$(< \"\#{HOME}/.cache/wal/wal\")\""

# reload
alias szsh="source ~/.zshrc"
alias sbash="source ~/.bashrc"
alias xreload="xrdb -load ~/.Xresources"

# -----
# https://github.com/jez/
# vvvvv

# up
alias cdd="cd .."
alias cddd="cd ../.."
alias cdddd="cd ../../.."
alias cddddd="cd ../../../.."
alias cdddddd="cd ../../../../.."
alias cddddddd="cd ../../../../../.."

# open multiple files in Vim tabs
alias vim &> /dev/null || alias vim="vim -p"
alias vimv="vim -O"

# lol
alias :q="clear"
alias clera="clear"
alias lcera="clear"
alias lcear="clear"

# look up LaTeX documentation
which texdef &> /dev/null && alias latexdef="texdef --tex latex"

# Easily download an MP3 from youtube on the command line
which youtube-dl &> /dev/null && alias youtube-mp3="youtube-dl --extract-audio --audio-format mp3"

# ----- aliases that are actually full-blown commands -------------------------
# list disk usage statistics for the current folder
alias duls="du -h -d1 | sort -hr"

# print ip
alias ip="curl ifconfig.co"

# How much memory is Chrome using right now?
alias chromemem="ps -ev | grep -i chrome | awk '{print \$12}' | awk '{for(i=1;i<=NF;i++)s+=\$i}END{print s}'"
