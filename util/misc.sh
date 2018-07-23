# environment variables
export DOTS="$HOME/.dotfiles" 
export VMDIR="$HOME/.dotfiles/host-vm-ubuntu"
export ASPIREDIR="$HOME/.dotfiles/host-aspire-ubuntu"
export CBDIR="$HOME/.dotfiles/host-cb-xfce"
export NPM_CONFIG_PREFIX="$HOME/.npm-global"

# import colorscheme from wal
(cat ~/.cache/wal/sequences &)

# get wal colors
. "$HOME/.cache/wal/colors.sh"

# Use Vim as the system-wide editor
if which nvim &> /dev/null; then
  export EDITOR="nvim"
else
  export EDITOR="vim"
fi

export PATH=$PATH:~/.cargo/bin
