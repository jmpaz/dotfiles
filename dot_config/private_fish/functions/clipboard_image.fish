function clipboard_image
    # Grab MIME types from the clipboard (captured, not printed)
    set -l types (wl-paste --list-types)

    # Pick the first image/* MIME quietly
    set -l mime ""
    for t in $types
        if string match -rq '^image/' $t   # -q keeps it silent
            set mime $t
            break
        end
    end

    # Exit if no image present
    if test -z "$mime"
        return 1
    end

    # Map MIME → extension
    switch $mime
        case image/png     ; set ext png
        case image/jpeg    ; set ext jpg
        case image/gif     ; set ext gif
        case image/webp    ; set ext webp
        case '*'           ; set ext bin
    end

    # Save and emit the path
    set -l out /tmp/copied-image.$ext
    wl-paste --type="$mime" > $out
    echo "@$out"
end

