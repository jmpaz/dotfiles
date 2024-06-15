# Creates or activates a Python virtual environment in the current directory

function venv
    # Check for the --no_direnv argument to determine if .envrc should be created
    set no_direnv_flag 0
    for arg in $argv
        if test "$arg" = --no_direnv
            set no_direnv_flag 1
            break
        end
    end

    if test -d ".venv"
        source .venv/bin/activate.fish
        echo "Virtual environment activated."
    else if test -d venv
        source venv/bin/activate.fish
        echo "Virtual environment activated."
    else
        echo "Virtual environment not found. Create one? (Y/n)"
        read choice
        switch $choice
            case '' Y y
                echo "Creating a new virtual environment..."
                uv venv
                echo "Virtual environment created."

                if test $no_direnv_flag -eq 0
                    # If --no_direnv was not passed, create and allow .envrc file
                    echo 'export VIRTUAL_ENV=.venv' >.envrc
                    echo 'layout python' >>.envrc
                    echo ".envrc file created."
                    direnv allow
                else
                    # Activate the environment immediately if --no_direnv was passed
                    source .venv/bin/activate.fish
                    echo "Virtual environment activated."
                end

                # install packages
                uv pip install jupyter_client ipykernel pynvim
            case '*'
                echo "Virtual environment creation cancelled."
        end
    end
end
