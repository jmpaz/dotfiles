function zellij_refresh
    # define a file to store the session name
    set -l session_file ~/.cache/zellij_last_session

    # try to retrieve the current session name
    set -l current_session (zellij list-sessions | rg '\[Created .*\] \(current\)' | string split " " | head -n1 | string replace -ra '\x1b\[[0-9;]*m' '')

    if test -n "$current_session"
        # cache the session name and detach
        echo $current_session >$session_file
        xdotool key alt+o d
    else
        if test -s $session_file
            set -l session_to_reconnect (cat $session_file)

            if test -n "$session_to_reconnect"
                # clear the file and reattach
                echo -n >$session_file
                zellij attach $session_to_reconnect
            else
                echo "Stored Zellij session name is empty."
            end
        else
            echo "No Zellij session was stored."
        end
    end
end
