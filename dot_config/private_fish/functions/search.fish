function search
    set -l engine perplexity # Default search engine
    set -l query ""

    # Parse arguments
    for arg in $argv
        switch $arg
            case -a
                set engine "are.na"
            case -p
                set engine perplexity
            case -m
                set engine metaphor
            case -gh
                set engine github
            case -sg
                set engine sourcegraph
            case --dest -d
                if set -q argv[2]
                    set engine $argv[2]
                    set argv $argv[2..-1]
                else
                    echo "Error: No search engine specified after --dest or -d"
                    return 1
                end
            case '*'
                if test -z $query
                    set query $arg
                end
        end
    end

    # Construct URL based on the selected search engine
    switch $engine
        case perplexity
            set url "https://www.perplexity.ai/search?q=$query&focus=internet&copilot=true"
        case metaphor
            set url "https://search.metaphor.systems/search?q=$query&filters=%7B%22domainFilterType%22%3A%22include%22%2C%22timeFilterOption%22%3A%22any_time%22%2C%22activeTabFilter%22%3A%22all%22%7D"
        case are.na
            set url "https://sander.are.na/search?q={%22term%22%3A{%22facet%22%3A%22$query%22}}"
        case github
            set url "https://github.com/search?q=$query&type=code"
        case sourcegraph
            set url "https://sourcegraph.com/search?q=$query"
        case '*'
            echo "Unsupported search engine: $engine"
            return 1
    end

    # Determine the OS and use the appropriate command to open the URL
    if uname | grep -iq darwin
        open $url
    else
        xdg-open $url
    end
end
