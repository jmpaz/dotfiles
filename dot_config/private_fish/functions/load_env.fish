function load_env
    set env_dir ~/.config/env

    # Check if the directory exists
    if not test -d $env_dir
        echo "Environment directory $env_dir does not exist."
        return
    end

    # Loop through each file in the env directory
    for file in $env_dir/*
        # Make sure it's a regular file
        if test -f $file
            echo "Loading file: $file"

            # Read each line in the file
            for line in (cat $file)
                # Skip empty lines and comments
                if test -z $line; or string match -r '^\s*#' -- $line
                    continue
                end

                # Split the line into key and value
                set key (string split -m 1 "=" -- $line)[1]
                set value (string split -m 1 "=" -- $line)[2]

                # Export the environment variable manually
                if test -n $key -a -n $value
                    set -gx $key $value
                end
            end
        end
    end
end

