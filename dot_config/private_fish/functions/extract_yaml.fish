function extract_yaml --description "Extract the first YAML code block from a markdown file"
    if test (count $argv) -ne 2
        echo "Usage: extract_yaml <input.md> <output.yaml>" >&2
        return 1
    end

    set -l input   $argv[1]
    set -l output  $argv[2]

    if not test -f "$input"
        echo "Error: input file not found: $input" >&2
        return 1
    end
    if not test -r "$input"
        echo "Error: cannot read input file: $input" >&2
        return 1
    end

    # ensure output ends in .yaml or .yml
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

    # extract the first ```yaml … ``` block with sed
    sed -n '/^```yaml[[:space:]]*$/,/^```[[:space:]]*$/p' "$input" | sed '1d;$d' > "$output"
    or begin
        echo "Error: failed to extract YAML block" >&2
        return $status
    end

    echo "YAML extracted to '$output'"
end

