function ip
    set os (uname)
    switch $os
        case Linux
            hostname -I 2>/dev/null | rg -o "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | head -n1
        case Darwin
            set ip (ipconfig getifaddr en0 2>/dev/null)
            if test -z "$ip"
                set ip (ifconfig | rg "inet " | rg -v "127\.0\.0\.1" | rg -o "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | head -n1)
            end
            echo $ip
        case '*'
            # Unknown OS fallback
            echo "Unable to determine IP on this platform."
            return 1
    end
end
