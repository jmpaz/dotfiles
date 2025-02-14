function git_edited
    # Check if exactly two arguments are provided.
    if test (count $argv) -ne 2
        echo "Usage: git_edited <hours> <path>"
        return 1
    end

    set hours $argv[1]
    set repo_path $argv[2]

    # Verify that the provided path is a directory.
    if not test -d $repo_path
        echo "Error: '$repo_path' is not a valid directory."
        return 1
    end

    # Use git log to list file changes since the specified time.
    # The --pretty=format: option outputs nothing for commit metadata,
    # while --name-only prints the affected file paths.
    # grep filters out any blank lines, and sort -u ensures uniqueness.
    git -C $repo_path log --since="$hours hours ago" --pretty=format: --name-only \
        | grep -E '^.+$' \
        | sort -u
end

