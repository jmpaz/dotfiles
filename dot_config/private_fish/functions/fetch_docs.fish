# https://github.com/jmpaz/contextualize

function fetch_docs
    # require at least one argument
    if test (count $argv) -lt 1
        echo "Usage: fetch_docs <target> [--flags ...]" >&2
        return 1
    end

    # pull out the target and any extra args
    set -l target $argv[1]
    set -l extra_args $argv[2..-1]
    set -l source

    switch $target
        case tridactyl
            set source https://github.com/tridactyl/tridactyl:src/static/clippy
        case ghostty
            set source https://github.com/ghostty-org/website:docs
        case '*'
            echo "Unsupported target: $target" >&2
            return 1
    end

    # if the user passed extra flags, include them before the source
    if test (count $extra_args) -gt 0
        contextualize cat $extra_args $source
    else
        contextualize cat $source
    end
end
