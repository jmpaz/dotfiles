# Import colorscheme from wal, pick one:
(wal -r &)
# setsid wal -r

# Use Vim as the system-wide editor
if which nvim &> /dev/null; then
  export EDITOR="nvim"
else
  export EDITOR="vim"
fi

# add cargo programs to path
export PATH=$PATH:~/.cargo/bin
