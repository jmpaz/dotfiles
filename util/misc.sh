# environment variables
export DOTS="$HOME/.dotfiles" 
export VMDIR="$HOME/.dotfiles/host-vm-ubuntu"
export CBDIR="$HOME/.dotfiles/host-cb-xfce"
export NPM_CONFIG_PREFIX="$HOME/.npm-global"

# Import colorscheme from wal, pick one:
(wal -r &)
# setsid wal -r

# Use Vim as the system-wide editor
if which nvim &> /dev/null; then
  export EDITOR="nvim"
else
  export EDITOR="vim"
fi

export PATH=$PATH:~/.cargo/bin
export PATH=$PATH:~/.bin
