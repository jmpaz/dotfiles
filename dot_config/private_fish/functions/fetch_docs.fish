# https://github.com/jmpaz/contextualize

function fetch_docs
    # require at least one argument
    if test (count $argv) -lt 1
        echo "Usage: fetch_docs <target[:subpath]> [--flags …]" >&2
        return 1
    end

    # pull out the target and any extra args
    set -l raw    $argv[1]
    set -l parts  (string split -m1 ":" $raw)
    set -l target $parts[1]
    set -l suffix $parts[2]

    set -l extra_args $argv[2..-1]

    switch $target
        case tridactyl
            set source https://github.com/tridactyl/tridactyl:src/static/clippy
        case ghostty
            set source https://github.com/ghostty-org/website:docs
        case rich
            set source https://github.com/Textualize/rich:docs/source
        case zk
            set source https://github.com/zk-org/zk.git:docs/{index.rst,config,notes,tips}
        case zk-nvim
            set source https://github.com/zk-org/zk-nvim.git:{README.md,doc,lua}
        case niri
            set source https://github.com/YaLTeR/niri.wiki.git:{*.md,examples}
        case '*'
            echo "Unsupported target: $target" >&2
            return 1
    end

    # if the user passed extra flags, include them before the source
    if test -n "$suffix"
        set source "$source/$suffix"
    end

    if test (count $extra_args) -gt 0
        contextualize cat $extra_args $source
    else
        contextualize cat $source
    end
end

