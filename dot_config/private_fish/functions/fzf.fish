function fzf --wraps=__fzf_original
    set -l opts (sh -c '
        [ -f "$HOME/.config/fzf/colors.sh" ] && . "$HOME/.config/fzf/colors.sh"
        [ -f "$HOME/.config/fzf/bindings.sh" ] && . "$HOME/.config/fzf/bindings.sh"
        printf "%s" "$FZF_DEFAULT_OPTS"
    ')
    set -gx FZF_DEFAULT_OPTS $opts
    command fzf $argv
end
