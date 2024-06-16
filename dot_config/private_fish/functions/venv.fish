function venv --description "create or activate a Python virtual environment in the current directory"
    # Check for the --no_direnv argument to determine if .envrc should be created
    set no_direnv_flag 0
    for arg in $argv
        if test "$arg" = --no_direnv
            set no_direnv_flag 1
            break
        end
    end

    function activate_venv
        set venv_path $argv[1]
        source $venv_path/bin/activate.fish
        echo "Virtual environment activated."
    end

    function create_pyproject_toml
        echo "[tool.pyright]" > pyproject.toml
        echo 'venvPath = "."' >> pyproject.toml
        echo 'venv = ".venv"' >> pyproject.toml
        echo "pyproject.toml file created."
    end

    function create_envrc
        echo 'export VIRTUAL_ENV=.venv' > .envrc
        echo 'layout python' >> .envrc
        echo ".envrc file created."
        direnv allow
    end

    if test -d ".venv"
        activate_venv .venv
    else if test -d "venv"
        activate_venv venv
    else
        echo "Virtual environment not found. Create one? (Y/n)"
        read choice
        switch $choice
            case '' Y y
                echo "Creating a new virtual environment..."
                uv venv
                echo "Virtual environment created."

                if test $no_direnv_flag -eq 0
                    create_envrc
                else
                    activate_venv .venv
                end

                create_pyproject_toml

                # install packages
                uv pip install jupyter_client ipykernel pynvim
            case '*'
                echo "Virtual environment creation cancelled."
        end
    end
end
