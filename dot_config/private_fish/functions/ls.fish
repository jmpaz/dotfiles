function ls
    # Flags to disable defaults if requested.
    set disable_group_flag 0
    set disable_icons_flag 0
    set -l new_args

    # Process arguments, stripping out our custom disabling flags.
    for arg in $argv
        if test "$arg" = "--no-group"
            set disable_group_flag 1
        else if test "$arg" = "--no-icons"
            set disable_icons_flag 1
        else
            set new_args $new_args $arg
        end
    end

    # Build the list of extra flags.
    set -l extra_flags
    if test $disable_group_flag -eq 0
        set extra_flags $extra_flags --group-directories-first
    end
    if test $disable_icons_flag -eq 0
        set extra_flags $extra_flags --icons
    end

    # Call the original exa with our extra flags first.
    command exa $extra_flags $new_args
end


