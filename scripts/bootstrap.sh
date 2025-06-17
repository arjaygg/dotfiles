#!/usr/bin/env bash

# Bootstrap script for setting up Nix and dotfiles on a fresh system
# Usage: ./scripts/bootstrap.sh

set -euo pipefail

echo "🚀 Bootstrapping Nix environment..."

# Install Nix
echo "📦 Installing Nix..."
if ! command -v nix &> /dev/null; then
    sh <(curl -L https://nixos.org/nix/install)
else
    echo "✅ Nix already installed"
fi

# Enable flakes and nix-command
echo "🔧 Enabling Nix flakes..."
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf

# Source Nix profile if not already sourced
if [[ ! -f ~/.nix-profile/etc/profile.d/nix.sh ]]; then
    echo "⚠️  Please restart your shell or source the Nix profile, then run this script again"
    exit 1
fi

source ~/.nix-profile/etc/profile.d/nix.sh

# Apply configuration
echo "⚙️  Applying dotfiles configuration..."
nix develop -c dot-apply

# Set Fish as default shell
echo "🐟 Setting Fish as default shell..."
if command -v fish &> /dev/null; then
    if ! grep -q "$(which fish)" /etc/shells; then
        which fish | sudo tee -a /etc/shells
    fi
    chsh -s "$(which fish)"
    echo "✅ Fish set as default shell"
else
    echo "⚠️  Fish not found, skipping shell change"
fi

echo "🎉 Bootstrap complete! Please restart your shell to use the new configuration."