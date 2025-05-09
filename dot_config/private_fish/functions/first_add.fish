function first_add
    git log --follow --diff-filter=A --format="%ad" --date=iso -- $argv[1] | tail -1
end

