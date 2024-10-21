function load_env
    set env_dir ~/.config/env

    # Check if the directory exists
    if not test -d $env_dir
        return
    end

    # Loop through each file in the env directory
    for file in $env_dir/*
        if test -f $file
            for line in (cat $file)
                # Skip empty lines and comments
                if test -z $line; or string match -r '^\s*#' -- $line
                    continue
                end

                set key (string split -m 1 "=" -- $line)[1]
                set value (string split -m 1 "=" -- $line)[2]

                if test -n $key -a -n $value
                    set -gx $key $value
                end
            end
        end
    end
end

