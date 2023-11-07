source ~/.config/fish/alias.fish
source ~/.asdf/asdf.fish

set -U fish_greeting "do great things."

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# vi + emacs bindings
function fish_user_key_bindings
    fish_default_key_bindings -M insert
    fish_vi_key_bindings --no-erase insert
end



# set paths
fish_add_path /home/josh/bin
fish_add_path /home/josh/.local/bin
fish_add_path /home/josh/Tools/consciousdata-cli/bin


# pyenv
pyenv init - | source
fish_add_path $PYENV_ROOT/bin

# cargo, go
fish_add_path /home/josh/.cargo/bin
fish_add_path /home/josh/go/bin


# Configure Jump
status --is-interactive; and source (jump shell fish | psub)

# Set InvokeAI path
set -gx INVOKEAI_ROOT /home/josh/Tools/invokeai/

# Set editor
set -gx EDITOR nvim

# Add flatpak dirs to path
set -gx XDG_DATA_DIRS $XDG_DATA_DIRS ~/.nix-profile/share/applications

set -l xdg_data_home $XDG_DATA_HOME ~/.local/share
set -gx --path XDG_DATA_DIRS $xdg_data_home[1]/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share

for flatpakdir in ~/.local/share/flatpak/exports/bin /var/lib/flatpak/exports/bin
    if test -d $flatpakdir
        contains $flatpakdir $PATH; or set -a PATH $flatpakdir
    end
end

# Syntax highlighting
set -g fish_color_autosuggestion 555 brblack
set -g fish_color_cancel -r
set -g fish_color_command --bold
set -g fish_color_comment red
set -g fish_color_cwd green
set -g fish_color_cwd_root red
set -g fish_color_end brmagenta
set -g fish_color_error brred
set -g fish_color_escape bryellow --bold
set -g fish_color_history_current --bold
set -g fish_color_host normal
set -g fish_color_match --background=brblue
set -g fish_color_normal normal
set -g fish_color_operator bryellow
set -g fish_color_param cyan
set -g fish_color_quote yellow
set -g fish_color_redirection brblue
set -g fish_color_search_match bryellow '--background=brblack'
set -g fish_color_selection white --bold '--background=brblack'
set -g fish_color_user brgreen
set -g fish_color_valid_path --underline

# Prompt
starship init fish | source
