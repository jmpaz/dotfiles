# hacks to run before everything else

# ensure that these directories are available to us
export PATH=".:$HOME/bin:/usr/local/bin:$PATH"

# set XDG Base Directories appropriately
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
