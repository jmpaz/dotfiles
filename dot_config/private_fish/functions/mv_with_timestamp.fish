function mv_with_timestamp
    # Check args
    if test (count $argv) -ne 2
        echo "Usage: mv_with_timestamp <file> <target_dir>"
        return 1
    end

    set file      $argv[1]
    set target_dir $argv[2]

    # Verify source file exists
    if not test -e $file
        echo "Error: file '$file' does not exist."
        return 1
    end

    # Verify target directory exists
    if not test -d $target_dir
        echo "Error: directory '$target_dir' does not exist."
        return 1
    end

    # Generate UTC timestamp
    set timestamp (date -u "+%Y-%m-%dT%H:%M:%SZ")

    # Extract the filename (basename) and split into base + ext
    set fname (basename $file)
    if string match -q '*.*' -- $fname
        # has an extension
        set ext  (string match -r '[^.]+$' $fname)
        set base (string replace -r '\.[^.]+$' '' $fname)
        set newname "$base"_"$timestamp"."$ext"
    else
        # no extension
        set newname "$fname"_"$timestamp"
    end

    # Move the file
    mv -- $file "$target_dir/$newname"
end

