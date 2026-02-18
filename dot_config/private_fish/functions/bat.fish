function bat --wraps=bat
    set -l bat_theme ansi
    set -l bat_style numbers,changes,header
    set -l bat_pager 'less -FR'

    if test -f ~/.config/bat/colors.sh
        set -l bat_settings (sh -c '. ~/.config/bat/colors.sh; printf "%s\n%s\n%s\n" "$BAT_THEME" "$BAT_STYLE" "$BAT_PAGER"')

        if test -n "$bat_settings[1]"
            set bat_theme $bat_settings[1]
        end
        if test -n "$bat_settings[2]"
            set bat_style $bat_settings[2]
        end
        if test -n "$bat_settings[3]"
            set bat_pager $bat_settings[3]
        end
    end

    env BAT_THEME="$bat_theme" BAT_STYLE="$bat_style" BAT_PAGER="$bat_pager" command bat $argv
end
