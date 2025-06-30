#!/bin/bash

# Alacritty Installation Script
set -e

echo "Installing Alacritty terminal configuration..."

# Install Alacritty if not present
if ! command -v alacritty &> /dev/null; then
    echo "Installing Alacritty..."
    sudo apt update
    sudo apt install -y alacritty
fi

# Create alacritty config directory
mkdir -p ~/.config/alacritty

# Backup existing config if it exists
if [ -f ~/.config/alacritty/alacritty.yml ]; then
    echo "Backing up existing alacritty config..."
    mv ~/.config/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml.backup.$(date +%Y%m%d_%H%M%S)
fi

# Copy alacritty config
cp "$(dirname "$0")/alacritty.yml" ~/.config/alacritty/alacritty.yml

# Download Catppuccin theme if available
echo "Downloading Catppuccin theme..."
curl -sL https://raw.githubusercontent.com/catppuccin/alacritty/main/catppuccin-mocha.yml -o ~/.config/alacritty/catppuccin-mocha.yml

echo "Alacritty configuration installed successfully!"