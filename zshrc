export DEFAULT_USER=josh
# export TERM="xterm-256color"
export ZSH=/home/josh/.oh-my-zsh
plugins=(git)
ZSH_THEME="gitsome"
source $ZSH/oh-my-zsh.sh
HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"

load_module() {
  if [ -n "$ABORTED" ]; then
    return
  fi

  module="$1"
  if [ -f "$module" ]; then
    source $module

    if [ "$?" != "0" ]; then
      echo "Module $module failed to load. Exiting."
      export ABORTED=1
      return
    fi
  fi
}

# check that shell is interactive - else stop
[ -z "$PS1" ] && return

load_module ~/.util/before.sh
load_module ~/.util/aliases.sh
load_module ~/.util/host.sh
load_module ~/.util/misc.sh

# load helper functions
for module in ~/.util/functions/*.sh; do
  load_module $module
done
