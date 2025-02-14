function edit
    # Separate arguments into file/dir args and fzf args using "--" as a separator.
    set file_args
    set fzf_args
    set in_fzf 0
    for arg in $argv
        if test "$arg" = "--"
            set in_fzf 1
            continue
        end
        if test $in_fzf -eq 1
            set fzf_args $fzf_args $arg
        else
            set file_args $file_args $arg
        end
    end

    # Classify file_args into files and directories.
    set files
    set dirs
    for arg in $file_args
        if test -f $arg
            set files $files $arg
        else if test -d $arg
            set dirs $dirs $arg
        else
            # If the path doesn't exist, assume it's a file.
            set files $files $arg
        end
    end

    # If any files were specified, open them directly using $EDITOR (or fallback to nvim).
    if test (count $files) -gt 0
        if set -q EDITOR
            $EDITOR $files
        else
            nvim $files
        end
        return 0
    end

    # If no directories were specified, default to the current directory.
    if test (count $dirs) -eq 0
        set dirs $PWD
    end

    # Use ripgrep to list matches within the specified directories.
    # The empty search pattern ('') lists every file with line and column numbers.
    set selection (rg --line-number --column --no-heading --color=always '' $dirs | \
                    fzf --ansi --delimiter ':' \
                        --preview 'bat --highlight-line {2} {1}' \
                        --preview-window '+{2}-/2' $fzf_args)

    # If no selection is made (fzf was cancelled), exit.
    if test -z "$selection"
        return 0
    end

    # Parse the selection, which is expected to be in the format:
    # filename:line:column:rest-of-match
    set file (echo $selection | awk -F: '{print $1}')
    set line (echo $selection | awk -F: '{print $2}')

    # Open the file in the editor, jumping to the selected line.
    if set -q EDITOR
        $EDITOR "$file" "+$line"
    else
        nvim "$file" "+$line"
    end
end

