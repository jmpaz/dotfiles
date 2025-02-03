function fzf --wraps=__fzf_original
    set -l opts (sh -c '. ~/.config/fzf/colors.sh; echo $FZF_DEFAULT_OPTS')
    set -gx FZF_DEFAULT_OPTS $opts
    command fzf $argv
end

