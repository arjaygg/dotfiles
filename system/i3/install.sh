#!/bin/bash

# i3 Installation Script
set -e

echo "Installing i3 window manager configuration..."

# Install i3 if not present
if ! command -v i3 &> /dev/null; then
    echo "Installing i3 window manager..."
    sudo apt update
    sudo apt install -y i3 i3-gaps i3lock i3status dmenu
fi

# Install additional tools used in i3 config
echo "Installing additional tools..."
sudo apt install -y \
    picom \
    mpd \
    dunst \
    feh \
    autorandr \
    nm-applet \
    rofi \
    playerctl \
    alsa-utils \
    pulseaudio-utils \
    brightnessctl

# Create i3 config directory
mkdir -p ~/.config/i3

# Backup existing config if it exists
if [ -f ~/.config/i3/config ]; then
    echo "Backing up existing i3 config..."
    mv ~/.config/i3/config ~/.config/i3/config.backup.$(date +%Y%m%d_%H%M%S)
fi

# Copy i3 config
cp "$(dirname "$0")/i3config" ~/.config/i3/config

echo "i3 configuration installed successfully!"
echo "Log out and select i3 as your session to use it."