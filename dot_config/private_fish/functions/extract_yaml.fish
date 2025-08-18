function extract_yaml --description "Extract the first YAML code block from markdown file(s)"
    if test (count $argv) -lt 1
        echo "Usage: extract_yaml <input.md> [input2.md ...]" >&2
        return 1
    end

    # validate input
    for input in $argv
        if not test -f "$input"
            echo "Error: input file not found: $input" >&2
            return 1
        end
        if not test -r "$input"
            echo "Error: cannot read input file: $input" >&2
            return 1
        end
    end

    # extract YAML
    set -l first 1
    for input in $argv
        # add separator
        if test $first -eq 0
            echo
            echo
        end
        set first 0

        # extract the first YAML block
        awk '
            BEGIN { in_block=0 }
            /^```yaml[[:space:]]*$/ { if (!found) { in_block=1; next } }
            /^```[[:space:]]*$/ { if (in_block) { in_block=0; found=1; exit } }
            { if (in_block) print }
        ' "$input"
    end
end

