function search
    if contains -- --help $argv; or contains -- -h $argv
        echo "Usage: search [options] [query]"
        echo
        echo "Options:"
        echo "  -c, --clipboard    Inject clipboard content into search"
        echo "  -p, --provider     Provider to use (default: claude)"
        echo "  -h, --help         Show this help message"
        echo
        echo "Examples:"
        echo "  search \"what is an inframodel\""
        echo "  search -c \"explain this code\""
        echo "  search -p chatgpt \"how do I write a fish function\""
        return 0
    end

    set -l clipboard_cmd
    if type -q pbpaste # macOS
        set clipboard_cmd pbpaste
    else if type -q wl-paste # Wayland
        set clipboard_cmd "wl-paste"
    else if type -q xclip # X11
        set clipboard_cmd "xclip -selection clipboard -o"
    else
        echo "Error: No clipboard command found. Please install xclip (X11) or wl-paste (Wayland)." >&2
        return 1
    end

    # Parse arguments for --clipboard/-c flag
    set -l clipboard_mode 0
    set -l other_args
    set -l query_text
    set -l provider_set 0

    set -l i 1
    while test $i -le (count $argv)
        set -l arg $argv[$i]
        switch $arg
            case --clipboard -c
                set clipboard_mode 1
            case -p --provider
                # Skip both the flag and its value
                set -a other_args $arg
                set i (math $i + 1)
                set -a other_args $argv[$i]
                set provider_set 1
            case '*'
                # Assume everything else is part of the query
                set -a query_text $arg
        end
        set i (math $i + 1)
    end

    # Set default provider if none specified
    if test $provider_set -eq 0
        set -a other_args -p claude
    end

    # If not in clipboard mode, just forward everything to s
    if test $clipboard_mode -eq 0
        s $other_args $query_text
        return
    end

    # Get clipboard content and preserve formatting
    set -l clip_content (eval $clipboard_cmd | string collect)

    # Check if clipboard is empty
    if test -z "$clip_content"
        echo "Error: Clipboard is empty" >&2
        return 1
    end

    # Format clipboard content according to presence/absence of triple backticks
    if string match -q '*```*' -- "$clip_content"
        begin
            echo '<paste>'
            echo $clip_content
            echo '</paste>'
            test (count $query_text) -gt 0 && echo $query_text
        end | s $other_args
    else
        begin
            echo '```paste'
            echo $clip_content
            echo '```'
            test (count $query_text) -gt 0 && echo $query_text
        end | s $other_args
    end
end
