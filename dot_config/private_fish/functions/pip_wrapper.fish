# wrapper to prevent unintentional installation of global packages

function pip_wrapper
    # Check if the first argument is 'install' and $VIRTUAL_ENV is not set
    if test "$argv[1]" = install -a -z "$VIRTUAL_ENV"
        set_color red
        echo "Warning: You are not in a virtual environment!"
        set_color normal

        # Output the prompt and then read input
        read --prompt-str "Continue? (y/N) " confirm
        switch $confirm
            case Y y
                # User confirmed, proceed with pip install
                command pip $argv
            case '*'
                # User did not confirm, do nothing
                echo "pip install cancelled."
        end
    else
        # If not installing or in a virtual environment, just run pip normally
        command pip $argv
    end
end
