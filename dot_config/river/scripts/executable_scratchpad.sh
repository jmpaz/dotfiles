#!/usr/bin/env bash

if [ -z "$1" ]; then
    echo "Error: No argument provided."
    exit 1
fi

# Define scratchpad configuration
declare -A apps
apps=(
    [terminal]="app_id=com.mitchellh.ghostty tag=$((1 << 19)) cmd='~/.local/bin/ghostty'"
    [browser]="app_id=zen-alpha tag=$((1 << 20)) cmd='gtk-launch zen_browser.desktop'"
    [discord]="app_id=discord tag=$((1 << 21)) cmd='gtk-launch com.discordapp.Discord.desktop'"
    [ferdium]="app_id=Ferdium tag=$((1 << 22)) cmd='gtk-launch org.ferdium.Ferdium.desktop'"
    [applemusic]="app_id=WebApp-AppleMusic6475 tag=$((1 << 23)) cmd='gtk-launch WebApp-AppleMusic6475.desktop'"
    [soundcloud]="app_id=WebApp-SoundCloud4871 tag=$((1 << 24)) cmd='gtk-launch webapp-SoundCloud4871.desktop'"
    [pavucontrol]="app_id=org.pulseaudio.pavucontrol tag=$((1 << 25)) cmd='pavucontrol'"
    [easyeffects]="app_id=com.github.wwmm.easyeffects tag=$((1 << 26)) cmd='gtk-launch com.github.wwmm.easyeffects.desktop'"
    [obs]="app_id=com.obsproject.Studio tag=$((1 << 27)) cmd='gtk-launch com.obsproject.Studio.desktop'"
)

# Get app configuration
config=${apps[$1]}
if [ -z "$config" ]; then
    echo "Error: Unknown application '$1'"
    exit 1
fi

# Parse configuration
eval "$config"

# Function to check if window exists
window_exists() {
    lswt | grep -q "^.*     ${app_id}"
}

# Function to toggle scratchpad
toggle_scratchpad() {
    if window_exists; then
        # Window exists, toggle its visibility
        riverctl toggle-focused-tags "$tag"
    else
        # Launch application
        eval "riverctl spawn \"$cmd\""

        # Wait for window with timeout
        local timeout=50
        local counter=0
        while ! window_exists && ((counter < timeout)); do
            sleep 0.1
            ((counter++))
        done

        if window_exists; then
            # Set just the scratchpad tag for the window
            riverctl set-view-tags "$tag"
            # Add scratchpad tag to current focus
            riverctl toggle-focused-tags "$tag"
        else
            echo "Error: Application failed to launch within timeout"
            exit 1
        fi
    fi
}

toggle_scratchpad

