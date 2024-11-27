# fullscreen rules
riverctl rule-add -app-id "mpv" fullscreen
riverctl rule-add -app-id "org.pwmt.zathura" fullscreen
riverctl rule-add -app-id "feh" fullscreen

# floating rules
riverctl rule-add -app-id "galculator" float
riverctl rule-add -app-id "org.kde.kcalc" float
riverctl rule-add -app-id "thunar" float
riverctl rule-add -app-id "Bitwarden" float
riverctl rule-add -app-id "Vial" float
riverctl rule-add -app-id "blueman-manager" float
riverctl rule-add -app-id "nm-connection-editor" float
riverctl rule-add -app-id "org.pulseaudio.pavucontrol" float
riverctl rule-add -app-id "com.github.wwmm.easyeffects" float
riverctl rule-add -app-id "GParted" float
riverctl rule-add -app-id "nwg-look" float
riverctl rule-add -app-id "mpv" float
riverctl rule-add -app-id "discord" float
riverctl rule-add -app-id "firefox" -title 'Picture-in-Picture' float
riverctl rule-add -app-id "zen-alpha" -title 'Picture-in-Picture' float
riverctl rule-add -app-id "io.github.elevenhsoft.WebApps" float
riverctl rule-add -app-id "WebApp-*" float

# dimensions
riverctl rule-add -app-id "dev.zed.Zed" dimensions 2400 1600
riverctl rule-add -app-id "dev.zed.Zed-Dev" dimensions 2400 1600
riverctl rule-add -app-id "com.mitchellh.ghostty" dimensions 1800 1200

# server-side decorations
riverctl rule-add ssd
riverctl rule-add -app-id "zen-alpha" ssd
riverctl rule-add -app-id "firefox" ssd
riverctl rule-add -app-id "com.github.wwmm.easyeffects" ssd
riverctl rule-add -app-id "com.mitchellh.ghostty" ssd
riverctl rule-add -app-id "dev.zed.Zed" ssd
riverctl rule-add -app-id "dev.zed.Zed-Dev" ssd
riverctl rule-add -app-id "io.github.elevenhsoft.WebApps" ssd
riverctl rule-add -app-id "WebApp-*" float
