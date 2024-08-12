function collect_context
    set -l files
    set -l issues
    set -l current_flag

    # Parse arguments
    for arg in $argv
        switch $arg
            case --files -f
                set current_flag "files"
            case --issues -i
                set current_flag "issues"
            case '-*'
                echo "Unknown option: $arg"
                return 1
            case '*'
                if test "$current_flag" = "files"
                    set -a files $arg
                else if test "$current_flag" = "issues"
                    set -a issues $arg
                else
                    echo "Argument '$arg' is not associated with any flag"
                    return 1
                end
        end
    end

    # Ensure files and issues are not empty
    if test (count $files) -eq 0
        echo "No files specified. Use --files or -f to specify files."
        return 1
    end
    if test (count $issues) -eq 0
        echo "No issues specified. Use --issues or -i to specify issues."
        return 1
    end

    # Execute commands
    begin
        contextualize cat --output clipboard $files
        and begin
            echo ""
            read -l -P "Fetch issue(s)? (Y/n) " confirm
            and begin
                switch $confirm
                    case '' Y y
                        echo ""
                        contextualize fetch --output clipboard $issues
                    case N n
                        echo "Operation cancelled by user"
                        return 1
                    case '*'
                        echo "Invalid input."
                        return 1
                end
            end
        end
    end; or return 1
end
