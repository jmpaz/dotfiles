function zk
    # If the current directory has a .zk folder, use the local notebook.
    if test -d .zk
        command zk $argv
    else
        # Otherwise, fall back to the notebook in ~/notes.
        command zk --working-dir ~/notes --notebook-dir ~/notes $argv
    end
end

