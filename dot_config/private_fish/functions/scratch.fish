# scratch - create/enter directories in ~/scratch/YYYY/
# format: YYYY/MM-DD@HH-MM-SS
# usage: scratch [-n|--new] [-l|--latest] [-r|--recent N]
#        scratch note [-n|--new] [-l|--latest]
# no args - enters today's most recent dir, or prompts to create one
# -n: creates new scratch dir silently
# -l: enters most recent dir globally
# -r N: enters Nth most recent dir (0-indexed)

function scratch
    set -l base_dir ~/scratch

    mkdir -p $base_dir

    if test (count $argv) -gt 0
        switch $argv[1]
            case "note"
                __scratch_handle_note $argv[2..-1]
                return $status
            case "--new" "-n"
                set -l new_dir (__scratch_new_dir_path)
                mkdir -p $new_dir
                cd $new_dir
                return
            case "--latest" "-l"
                if test (count $argv) -gt 1
                    echo "Error: --latest doesn't accept additional arguments"
                    return 1
                end
                set -l latest (__scratch_find_all | head -n1)
                if test -n "$latest"
                    cd $latest
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
                set -l target (__scratch_find_all | sed -n (math $argv[2] + 1)"p")
                if test -n "$target"
                    cd $target
                    return
                end
                echo "No scratch directory at index $argv[2]"
                return 1
        end
    end

    __scratch_ensure_today_dir --prompt
end

function __scratch_new_dir_path
    set -l base_dir ~/scratch
    set -l year (date '+%Y')
    set -l date (date '+%m-%d')
    set -l time (date '+%H-%M-%S')
    echo "$base_dir/$year/$date@$time"
end

function __scratch_find_all
    # Returns all scratch dirs sorted newest-first (globally across years)
    # Year prefix ensures lexicographic sort equals chronological sort
    find ~/scratch -mindepth 2 -maxdepth 2 -type d -name '*@*' \
        -not -path '*/.git/*' \
        -not -path '*/archive/*' 2>/dev/null | sort -r
end

function __scratch_find_today
    # Returns today's most recent dir if it exists
    set -l base_dir ~/scratch
    set -l year (date '+%Y')
    set -l date (date '+%m-%d')
    set -l year_dir "$base_dir/$year"

    if test -d $year_dir
        find $year_dir -maxdepth 1 -type d -name "$date@*" 2>/dev/null | sort -r | head -n1
    end
end

function __scratch_ensure_today_dir
    set -l prompt_mode 0
    for arg in $argv
        switch $arg
            case "--prompt"
                set prompt_mode 1
        end
    end

    set -l today_dir (__scratch_find_today)

    if test -n "$today_dir"
        cd $today_dir
        return 0
    end

    if test $prompt_mode -eq 1
        read -l -P "Create new scratch directory for today? [Y/n] " confirm
        if test $status -ne 0
            echo "Aborted."
            return 1
        end
        if test -n "$confirm" -a "$confirm" != "y" -a "$confirm" != "Y"
            echo "Aborted."
            return 1
        end
    end

    set -l new_dir (__scratch_new_dir_path)
    mkdir -p $new_dir
    cd $new_dir
    return 0
end

function __scratch_display_path -a full_path
    set -l current_year (date '+%Y')
    set -l path_year (string match -r '/(\d{4})/' $full_path | tail -n1)
    set -l leaf (basename $full_path)

    if test "$path_year" = "$current_year"
        echo $leaf
    else
        echo "$path_year/$leaf"
    end
end

function __scratch_handle_note
    set -l force_new 0

    for arg in $argv
        switch $arg
            case "--new" "-n"
                set force_new 1
            case "--latest" "-l"
                # -l is default behavior, just ignore
        end
    end

    # Check if we're in a scratch directory
    if not string match -q -r '\d{2}-\d{2}@' $PWD
        # Not in a scratch dir - silently ensure one exists
        __scratch_ensure_today_dir
        if test $status -ne 0
            echo "Cannot create/open notes without a scratch directory."
            return 1
        end
    end

    if not test -d "notes"
        mkdir -p notes
    end

    set -l current_time (date '+%H-%M@%Ss.md')

    if test $force_new -eq 1
        $EDITOR "notes/$current_time"
        return
    end

    # Default: open most recent note if it exists
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
