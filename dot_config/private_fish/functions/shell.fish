function shell
    argparse g/git h/gh -- $argv
    set -l type shell
    if set -q _flag_git
        set type git
    else if set -q _flag_gh
        set type gh
    end
    gh copilot suggest "$argv[-1]" -t $type
end
