# misc
alias todo="todotxt-machine"
alias toclip="xclip -selection c"

# feh/wal
alias fehs="feh -. -S filename" # scale down to window and sort by filename
alias fehwal="feh --bg-scale \"\$(< \"\#{HOME}/.cache/wal/wal\")\""
alias walnobg="wal -n -ti"
alias walxr="cat ~/.cache/wal/colors.Xresources"

# config
alias dots="cd ~/.dotfiles"
alias .s="cd ~/.dotfiles"
alias monconf="vim $DBIN/monitor.sh"
alias zshconf="vim ~/.zshrc"
alias alconf="vim ~/.util/aliases.sh"
alias vmconf="vim $VMDIR/util/host.sh"
alias cbconf="vim $CBDIR/util/host.sh"
alias xrconf="vim ~/.Xresources"
alias i3conf="vim ~/.config/i3/config"
alias i3conf-vm="vim $VMDIR/config/i3/config"
alias i3conf-cb="vim $CBDIR/config/i3/config"
alias polyconf="vim ~/.config/polybar/config"
alias roficonf="vim ~/.config/rofi/config.rasi"
alias vimconf="vim ~/.vimrc"
alias termconf="vim ~/.config/terminator/config"
alias compconf="vim ~/.compton.conf"
alias todoconf="vim ~/.todotxt-machinerc"
alias todoref="todoconf && todotxt-machine"

# reload
alias szsh="source ~/.zshrc"
alias sbash="source ~/.bashrc"
alias xreload="xrdb -load ~/.Xresources"
alias :q="exit"
alias quit="exit"
alias la="ls -A"
alias cdu="cd .."
alias cduu="cd ../.."
alias cdu2="cd ../.."
alias cdu3="cd ../../.."
alias cdu4="cd ../../../.."
alias cdu5="cd ../../../../.."

# ls replacements
alias exa="exa --group-directories-first"
alias exal="exa -l"
alias exaa="exa -a"
alias exaal="exa -la"
alias exala="exa -la"
alias exall="exa -la"
alias cls="colorls -sd"
alias cla="colorls -sd -A"

# open multiple files in Vim tabs
alias vim &> /dev/null || alias vim="vim -p"
alias vimv="vim -O"

alias clera="clear"
alias lcera="clear"
alias lcear="clear"

# look up LaTeX documentation
which texdef &> /dev/null && alias latexdef="texdef --tex latex"

# Easily download an MP3 from youtube on the command line
which youtube-dl &> /dev/null && alias youtube-mp3="youtube-dl --extract-audio --audio-format mp3"

# list disk usage statistics for the current folder
alias duls="du -h -d1 | sort -hr"

# print ip
alias ip="curl ifconfig.co"
