function first_add -d "Get the date a file was first added to git"
    argparse h/help l/local 't/tz=' -- $argv
    or return

    if set -q _flag_help
        echo "Usage: first_add [OPTIONS] FILE"
        echo ""
        echo "Get the date a file was first added to git"
        echo ""
        echo "Options:"
        echo "  -l, --local     Use local timezone (default: UTC)"
        echo "  -t, --tz=TZ     Use specified timezone (e.g., America/New_York)"
        echo "  -h, --help      Show this help message"
        return 0
    end

    set -l tz UTC
    if set -q _flag_local
        set tz (date +%Z)
    else if set -q _flag_tz
        set tz $_flag_tz
    end

    set -l suffix ""
    test $tz = UTC && set suffix Z
    TZ=$tz git log --follow --diff-filter=A --format="%ad$suffix" --date=format-local:'%Y-%m-%dT%H:%M:%S' -- $argv[1] | tail -1
end

