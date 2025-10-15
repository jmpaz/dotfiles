function envrc --description "ensure .envrc and project configuration for supported languages"
    if test (count $argv) -eq 0
        echo "Usage: envrc <lang>"
        return 1
    end

    set -l lang (string lower -- $argv[1])

    function __envrc_pyproject_plan
        set -l pyproject_path pyproject.toml
        set -l needs_init 0
        set -l needs_section 1
        set -l needs_venv_path 1
        set -l needs_venv 1

        if not test -f $pyproject_path
            set needs_init 1
        else
            set needs_section 1
            set needs_venv_path 1
            set needs_venv 1

            set -l pyright_section 0
            while read -l line
                if string match -q "[tool.pyright]" $line
                    set pyright_section 1
                    set needs_section 0
                    continue
                end

                if string match -rq '^\[' -- $line
                    set pyright_section 0
                end

                if test $pyright_section -eq 1
                    if string match -q 'venvPath = "."' $line
                        set needs_venv_path 0
                        continue
                    else if string match -q 'venv = ".venv"' $line
                        set needs_venv 0
                        continue
                    end
                end
            end < $pyproject_path
        end

        printf '%s\n' $needs_init $needs_section $needs_venv_path $needs_venv
    end

    function __envrc_pyproject_apply
        set -l needs_init $argv[1]
        set -l needs_section $argv[2]
        set -l needs_venv_path $argv[3]
        set -l needs_venv $argv[4]
        set -l pyproject_path pyproject.toml

        if test $needs_init -eq 1
            if not command -sq uv
                echo "envrc: uv is required to initialize pyproject.toml." >&2
                return 1
            end
            echo "pyproject.toml not found. Initializing with 'uv init'..."
            echo ""
            uv init
            if test $status -ne 0
                echo "envrc: 'uv init' failed." >&2
                return 1
            end
            echo "pyproject.toml created via 'uv init'."
            echo ""
        end

        if test $needs_section -eq 1 -o $needs_venv_path -eq 1 -o $needs_venv -eq 1
            if test $needs_section -eq 1
                if test -s $pyproject_path
                    echo "" >> $pyproject_path
                end
                echo "[tool.pyright]" >> $pyproject_path
            end

            if test $needs_venv_path -eq 1
                echo 'venvPath = "."' >> $pyproject_path
            end
            if test $needs_venv -eq 1
                echo 'venv = ".venv"' >> $pyproject_path
            end

            if test $needs_init -eq 1
                echo "pyproject.toml populated with pyright settings."
            else
                echo "pyproject.toml updated with pyright settings."
            end
            echo ""
        else if test $needs_init -eq 0
            echo "pyproject.toml already configured for pyright."
            echo ""
        end
    end

    function __envrc_handle_python
        set -l envrc_path .envrc
        set -l envrc_action none
        set -l envrc_new_lines
        set -l envrc_needs_direnv 0

        if not test -f $envrc_path
            set envrc_action create
            set envrc_new_lines 'export VIRTUAL_ENV=.venv' 'layout python'
        else
            set -l envrc_lines
            while read -l line
                set -a envrc_lines $line
            end < $envrc_path

            set -l new_envrc_lines
            set -l virtual_env_present 0
            set -l layout_present 0
            set -l virtual_env_written 0
            set -l layout_written 0
            set -l modifications 0

            for line in $envrc_lines
                set -l trimmed (string trim -- $line)

                if string match -rq '^[[:space:]]*export[[:space:]]+VIRTUAL_ENV=' -- $trimmed
                    if test $virtual_env_written -eq 0
                        set virtual_env_present 1
                        if test $trimmed != 'export VIRTUAL_ENV=.venv'
                            set modifications 1
                        end
                        set -a new_envrc_lines 'export VIRTUAL_ENV=.venv'
                        set virtual_env_written 1
                    else
                        set modifications 1
                    end
                    continue
                end

                if string match -rq '^[[:space:]]*layout[[:space:]]+' -- $trimmed
                    if test $layout_written -eq 0
                        set layout_present 1
                        if test $trimmed != 'layout python'
                            set modifications 1
                        end
                        set -a new_envrc_lines 'layout python'
                        set layout_written 1
                    else
                        set modifications 1
                    end
                    continue
                end

                set -a new_envrc_lines $line
            end

            set -l header_lines

            if test $virtual_env_present -eq 0
                set modifications 1
                set -a header_lines 'export VIRTUAL_ENV=.venv'
            end

            if test $layout_present -eq 0
                set modifications 1
                set -a header_lines 'layout python'
            end

            if test $modifications -eq 1
                if test (count $header_lines) -gt 0
                    if test (count $new_envrc_lines) -gt 0
                        set header_lines $header_lines ''
                    end
                    set new_envrc_lines $header_lines $new_envrc_lines
                end

                set envrc_action update
                set envrc_new_lines $new_envrc_lines
            else
                set envrc_action none
            end
        end

        set -l pyproject_plan (__envrc_pyproject_plan)
        set -l needs_init $pyproject_plan[1]
        set -l needs_section $pyproject_plan[2]
        set -l needs_venv_path $pyproject_plan[3]
        set -l needs_venv $pyproject_plan[4]

        if test $needs_init -eq 1
            if not command -sq uv
                echo "envrc: uv is required to initialize pyproject.toml." >&2
                return 1
            end
        end

        set -l planned_actions
        if test $envrc_action = create
            set -a planned_actions "create .envrc with python layout"
        else if test $envrc_action = update
            set -a planned_actions "update .envrc to enforce python layout"
        end
        if test $needs_init -eq 1
            set -a planned_actions "initialize pyproject.toml via 'uv init'"
        end
        if test $needs_section -eq 1 -o $needs_venv_path -eq 1 -o $needs_venv -eq 1
            set -a planned_actions "ensure pyproject.toml has pyright venv settings"
        end

        if test (count $planned_actions) -eq 0
            echo "Nothing to do for python envrc."
            return 0
        end

        echo "envrc will perform:"
        for action in $planned_actions
            echo "  - $action"
        end
        echo ""
        echo "Proceed? (Y/n)"
        read choice
        set -l read_status $status

        if test $read_status -ne 0
            echo ""
            echo "envrc cancelled."
            return 1
        end

        switch $choice
            case '' Y y
                echo ""
            case '*'
                echo ""
                echo "envrc cancelled."
                return 1
        end

        if test $envrc_action = create
            printf '%s\n' $envrc_new_lines > $envrc_path
            echo ".envrc created with python layout."
            echo ""
            set envrc_needs_direnv 1
        else if test $envrc_action = update
            printf '%s\n' $envrc_new_lines > $envrc_path
            echo ".envrc updated for python layout."
            echo ""
            set envrc_needs_direnv 1
        end

        __envrc_pyproject_apply $needs_init $needs_section $needs_venv_path $needs_venv
        if test $status -ne 0
            return $status
        end

        if test $envrc_needs_direnv -eq 1
            direnv allow
        end
    end

    switch $lang
        case python py
            __envrc_handle_python
        case '*'
            echo "envrc: unsupported language '$argv[1]'."
            return 1
    end
end
