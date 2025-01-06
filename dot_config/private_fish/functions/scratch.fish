# scratch - create/enter directories in ~/scratch
# format: MM-DD@HH.MM
# usage: scratch [-n|--new] [-l|--latest] [-r|--recent N]
# no args - enters today's most latest dir, or prompts to create one
# -n: creates new scratch dir
# -l: enters most recent dir
# -r N: enters Nth most recent dir (0-indexed)

function scratch
    set -l base_dir ~/scratch
    set -l current_date (date '+%m-%d')
    set -l current_time (date '+%H-%M-%S')
    set -l new_dir "$base_dir/$current_date@$current_time"

    mkdir -p $base_dir

    # Handle subcommands
    if test (count $argv) -gt 0
        switch $argv[1]
            case "note"
                __scratch_handle_note $argv[2..-1]
                return $status
            case "--new" "-n"
                mkdir -p $new_dir
                cd $new_dir
                return
            case "--latest" "-l"
                if test (count $argv) -gt 1
                    echo "Error: --latest doesn't accept additional arguments"
                    return 1
                end
                set -l dirs (find $base_dir -mindepth 1 -maxdepth 1 -type d -not -name '.git' -not -name 'archive' 2>/dev/null)
                if test (count $dirs) -gt 0
                    set -l latest_dir (string join \n $dirs | sort -r | head -n1)
                    cd $latest_dir
                    return
                end
                echo "No scratch directories found"
                return 1
            case "--recent" "-r"
                if test (count $argv) -ne 2
                    echo "Error: --recent requires a number argument"
                    return 1
                end
                if not string match -qr '^[0-9]+$' $argv[2]
                    echo "Error: --recent argument must be a number"
                    return 1
                end
                set -l dirs (find $base_dir -mindepth 1 -maxdepth 1 -type d -not -name '.git' -not -name 'archive' 2>/dev/null)
                if test (count $dirs) -gt 0
                    set -l target_dir (string join \n $dirs | sort -r | sed -n (math $argv[2] + 1)"p")
                    if test -n "$target_dir"
                        cd $target_dir
                        return
                    end
                    echo "No scratch directory at index $argv[2]"
                    return 1
                end
                echo "No scratch directories found"
                return 1
        end
    end

    __scratch_ensure_today_dir
end

function __scratch_ensure_today_dir
    set -l base_dir ~/scratch
    set -l current_date (date '+%m-%d')
    set -l current_time (date '+%H-%M-%S')
    set -l new_dir "$base_dir/$current_date@$current_time"

    mkdir -p $base_dir

    set -l dirs (find $base_dir -mindepth 1 -maxdepth 1 -type d -not -name '.git' -not -name 'archive' 2>/dev/null)
    if test (count $dirs) -gt 0
        set -l latest_dir (string join \n $dirs | sort -r | head -n1)
        set -l latest_date (string match -r '\d{2}-\d{2}' $latest_dir)

        if test "$latest_date" = "$current_date"
            cd $latest_dir
            return 0
        end
    end

    read -l -P "Create new scratch directory for today? [Y/n] " confirm
    if test $status -ne 0
        echo "Aborted."
        return 1
    end

    if test -z "$confirm" -o "$confirm" = "y" -o "$confirm" = "Y"
        mkdir -p $new_dir
        cd $new_dir
        return 0
    else
        echo "Aborted."
        return 1
    end
end


function __scratch_handle_note
    set -l force_new 0
    set -l use_latest 0

    # Parse flags for note
    for arg in $argv
        switch $arg
            case "--new" "-n"
                set force_new 1
            case "--latest" "-l"
                set use_latest 1
        end
    end

    if test $force_new -eq 1 -a $use_latest -eq 1
        echo "Error: --new and --latest are mutually exclusive"
        return 1
    end

    # Check if we're in a scratch directory. If not, try to ensure one.
    if not string match -q -r '\d{2}-\d{2}@' $PWD
        __scratch_ensure_today_dir
        if test $status -ne 0
            # User opted not to create a new directory
            echo "Cannot create/open notes without a scratch directory."
            return 1
        end
    end

    # Ensure notes directory is properly structured
    if test -d "notes/notes"
        mv notes/notes/* notes/ 2>/dev/null
        rm -rf notes/notes
    end

    if not test -d "notes"
        mkdir -p notes
    end

    set -l current_time (date '+%H-%M@%Ss.md')

    if test $force_new -eq 1
        $EDITOR "notes/$current_time"
        return
    end

    # Default or --latest: open most recent note if it exists
    set -l latest_note (find notes/ -maxdepth 1 -name "*.md" -type f 2>/dev/null | sort -r | head -n1)
    if test -n "$latest_note"
        $EDITOR $latest_note
        return
    end

    # No notes exist, prompt
    read -l -P "No notes exist. Create new note? [Y/n] " confirm
    if test -z "$confirm" -o "$confirm" = "y" -o "$confirm" = "Y"
        $EDITOR "notes/$current_time"
    else
        echo "No note created."
        return 1
    end
end

