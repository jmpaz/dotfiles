function resume_if_empty --description 'Resume last suspended job when prompt is empty'
    set -l buffer (commandline --current-buffer)

    if test -n "$buffer"
        commandline -f repaint
        return
    end

    if not jobs -q
        commandline -f repaint
        return
    end

    commandline --replace 'fg'
    commandline -f execute
end
