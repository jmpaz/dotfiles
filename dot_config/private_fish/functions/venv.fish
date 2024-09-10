function venv --description "create, activate, or reinitialize a Python virtual environment in the current directory"
    set no_direnv_flag 0
    set reinit_flag 0

    for arg in $argv
        switch $arg
            case --no_direnv
                set no_direnv_flag 1
            case --reinit
                set reinit_flag 1
        end
    end

    function activate_venv
        set venv_path $argv[1]
        source $venv_path/bin/activate.fish
        echo "Virtual environment activated."
    end

    function set_pyproject_toml
        if not test -f pyproject.toml
            echo "[tool.pyright]" > pyproject.toml
            echo 'venvPath = "."' >> pyproject.toml
            echo 'venv = ".venv"' >> pyproject.toml
            echo "pyproject.toml file created."
        else
            set pyright_section 0
            set venv_path_set 0
            set venv_set 0
            while read -l line
                if string match -q "[tool.pyright]" $line
                    set pyright_section 1
                else if test $pyright_section -eq 1
                    if string match -q 'venvPath = "."' $line
                        set venv_path_set 1
                    else if string match -q 'venv = ".venv"' $line
                        set venv_set 1
                    end
                end
            end < pyproject.toml

            if test $pyright_section -eq 0
                echo "" >> pyproject.toml
                echo "[tool.pyright]" >> pyproject.toml
            end
            if test $venv_path_set -eq 0
                echo 'venvPath = "."' >> pyproject.toml
            end
            if test $venv_set -eq 0
                echo 'venv = ".venv"' >> pyproject.toml
            end
            echo "pyproject.toml file updated."
        end
    end

    function set_envrc
        if not test -f .envrc
            echo 'export VIRTUAL_ENV=.venv' > .envrc
            echo 'layout python' >> .envrc
            echo ".envrc file created."
            direnv allow
        else
            set virtual_env_set 0
            set layout_python_set 0
            while read -l line
                if string match -q 'export VIRTUAL_ENV=.venv' $line
                    set virtual_env_set 1
                else if string match -q 'layout python' $line
                    set layout_python_set 1
                end
            end < .envrc

            if test $virtual_env_set -eq 0
                echo 'export VIRTUAL_ENV=.venv' >> .envrc
            end
            if test $layout_python_set -eq 0
                echo 'layout python' >> .envrc
            end
            echo ".envrc file updated."
            direnv allow
        end
    end

    if test $reinit_flag -eq 1
        if set -q VIRTUAL_ENV
            set -e VIRTUAL_ENV
            set -e PATH
            set -x PATH $PATH
        end
        if test -d ".venv"
            rm -rf .venv
            echo "Existing .venv directory removed."
        end
        echo "Reinitializing virtual environment..."
        uv venv
        echo "Virtual environment reinitialized."

        if test $no_direnv_flag -eq 0
            set_envrc
        else
            activate_venv .venv
        end

        set_pyproject_toml

        # install packages
        uv pip install jupyter_client ipykernel pynvim
        return
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
                    set_envrc
                else
                    activate_venv .venv
                end

                set_pyproject_toml

                # install packages
                uv pip install jupyter_client ipykernel pynvim
            case '*'
                echo "Virtual environment creation cancelled."
        end
    end
end
