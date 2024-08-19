function scroll -d "Create empty space"
    set count (math $argv[1] - 1)
    for i in (seq $count)
        echo ""
    end
end
