function tmux
    # from https://github.com/zellij-org/zellij/blob/489c4da5ffaf38526b76bad4ce09da63ae99331e/src/sessions.rs#L466C34-L600
    set adjectives "adamant" "adept" "adventurous" "arcadian" "auspicious" "awesome" "blossoming" "brave" "charming" "chatty" "circular" "considerate" "cubic" "curious" "delighted" "didactic" "diligent" "effulgent" "erudite" "excellent" "exquisite" "fabulous" "fascinating" "friendly" "glowing" "gracious" "gregarious" "hopeful" "implacable" "inventive" "joyous" "judicious" "jumping" "kind" "likable" "loyal" "lucky" "marvellous" "mellifluous" "nautical" "oblong" "outstanding" "polished" "polite" "profound" "quadratic" "quiet" "rectangular" "remarkable" "rusty" "sensible" "sincere" "sparkling" "splendid" "stellar" "tenacious" "tremendous" "triangular" "undulating" "unflappable" "unique" "verdant" "vitreous" "wise" "zippy"
    set nouns "aardvark" "accordion" "apple" "apricot" "bee" "brachiosaur" "cactus" "capsicum" "clarinet" "cowbell" "crab" "cuckoo" "cymbal" "diplodocus" "donkey" "drum" "duck" "echidna" "elephant" "foxglove" "galaxy" "glockenspiel" "goose" "hill" "horse" "iguanadon" "jellyfish" "kangaroo" "lake" "lemon" "lemur" "magpie" "megalodon" "mountain" "mouse" "muskrat" "newt" "oboe" "ocelot" "orange" "panda" "peach" "pepper" "petunia" "pheasant" "piano" "pigeon" "platypus" "quasar" "rhinoceros" "river" "salamander" "sitar" "stegosaurus" "tambourine" "tiger" "tomato" "triceratops" "ukulele" "viola" "weasel" "xylophone" "yak" "zebra"

    set adjective (printf '%s\n' $adjectives | shuf -n1)
    set noun (printf '%s\n' $nouns | shuf -n1)

    set session_name "$adjective-$noun"

    set tmux_config "$HOME/.config/tmux/tmux.conf"

    # create a new session if there are no arguments
    if test (count $argv) -eq 0
        command tmux -f $tmux_config new-session -s $session_name
    else
        switch $argv[1]
            case 'new-session'
                if not contains -s $argv '-s'
                    set argv $argv -s $session_name
                end
                command tmux -f $tmux_config $argv
            case '*'
                command tmux -f $tmux_config $argv
        end
    end
end

