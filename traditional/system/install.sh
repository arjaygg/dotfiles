#!/bin/bash

# System Tools Installation Script
set -e

echo "Installing system tools and utilities..."

# Update package list
sudo apt update

# Install system tools
echo "Installing essential system tools..."
sudo apt install -y \
    exa \
    bat \
    fd-find \
    zoxide \
    fzf \
    htop \
    curl \
    git \
    fish

# Create ~/.bin directory if it doesn't exist
mkdir -p ~/.bin

# Create symlinks for Ubuntu's differently named packages
if command -v fdfind &> /dev/null; then
    ln -sf $(which fdfind) ~/.bin/fd
    echo "Created fd symlink"
fi

if command -v batcat &> /dev/null; then
    ln -sf $(which batcat) ~/.bin/bat
    echo "Created bat symlink"
fi

# Ensure ~/.bin is in PATH
if ! echo $PATH | grep -q "$HOME/.bin"; then
    echo 'export PATH="$HOME/.bin:$PATH"' >> ~/.bashrc
    echo "Added ~/.bin to PATH in ~/.bashrc"
fi

# Install Fish shell configurations if Fish is available
if command -v fish &> /dev/null; then
    echo "Configuring Fish shell..."
    
    # Install Fisher (Fish plugin manager)
    fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
    
    # Copy Fish configuration files
    mkdir -p ~/.config/fish/conf.d
    mkdir -p ~/.config/fish/functions
    
    # Copy function files
    if [ -d "$(dirname "$0")/functions" ]; then
        cp -r "$(dirname "$0")/functions"/* ~/.config/fish/functions/
    fi
    
    # Copy configuration files
    if [ -d "$(dirname "$0")/conf.d" ]; then
        cp -r "$(dirname "$0")/conf.d"/* ~/.config/fish/conf.d/
    fi
    
    # Initialize zoxide for Fish if available
    if command -v zoxide &> /dev/null; then
        fish -c "zoxide init fish > ~/.config/fish/conf.d/zoxide.fish"
    fi
    
    echo "Fish shell configured!"
fi

echo "System tools installation completed successfully!"