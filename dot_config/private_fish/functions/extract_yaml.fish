function extract_yaml --description "Extract the first YAML code block from a markdown file"
    # require 1 or 2 args
    set -l argc (count $argv)
    if test $argc -lt 1 -o $argc -gt 2
        echo "Usage: extract_yaml <input.md> [output.yaml]" >&2
        return 1
    end

    set -l input $argv[1]

    # validate input
    if not test -f "$input"
        echo "Error: input file not found: $input" >&2
        return 1
    end
    if not test -r "$input"
        echo "Error: cannot read input file: $input" >&2
        return 1
    end

    # if an output file was provided, validate it
    if test $argc -eq 2
        set -l output $argv[2]

        # ensure .yaml or .yml
        if not string match -rq '\.ya?ml$' -- $output
            echo "Error: output file must end in .yaml or .yml" >&2
            return 1
        end

        if test "$input" = "$output"
            echo "Error: input and output must be different files" >&2
            return 1
        end

        if test -e "$output"
            read -P "File '$output' already exists. Overwrite? (y/N) " ans
            if not string match -qr '^(?i:y|yes)$' -- $ans
                echo "Aborted." >&2
                return 1
            end
        end

        # extract only the first YAML block
        awk '
            BEGIN { in_block=0 }
            /^```yaml[[:space:]]*$/ { if (!found) { in_block=1; next } }
            /^```[[:space:]]*$/ { if (in_block) { in_block=0; found=1; exit } }
            { if (in_block) print }
        ' "$input" > "$output"

        if test (count (cat "$output")) -eq 0
            echo "Error: failed to extract YAML block" >&2
            return 1
        end
        echo "YAML extracted to '$output'"

    else
        # dump to stdout
        awk '
            BEGIN { in_block=0 }
            /^```yaml[[:space:]]*$/ { if (!found) { in_block=1; next } }
            /^```[[:space:]]*$/ { if (in_block) { in_block=0; found=1; exit } }
            { if (in_block) print }
        ' "$input"
    end
end

