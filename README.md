# 🏠 Hybrid Dotfiles (Enhanced)

This is a modern, flexible dotfiles configuration supporting both Nix and traditional installation methods.

Originally based on caarlos0/dotfiles, now enhanced with:
- **🔀 Hybrid Architecture**: Choose between Nix or traditional package managers
- **🐚 Smart Shell Selection**: Fish preferred with Bash fallback
- **🌍 Cross-Platform Support**: macOS, Linux, WSL compatibility
- **📦 Auto-Detection**: Intelligent environment analysis

## 📚 Documentation

- **[Hybrid Setup Guide](HYBRID-SETUP.md)** - Complete architecture overview
- **[Shell Configuration Guide](SHELL-GUIDE.md)** - Shell selection and setup

## ⚡ Quick Start (New Hybrid Method)

```bash
git clone https://github.com/arjaygg/dotfilesnixOS.git ~/.dotfiles
cd ~/.dotfiles
./install.sh  # Auto-detects best method (Nix or traditional)
```

You can see the history on these repositories:

- [dotfiles.zsh](https://github.com/caarlos0/dotfiles.zsh)
- [dotfiles.fish](https://github.com/caarlos0/dotfiles.fish)

This configuration supports both the original Nix-focused approach and new hybrid methods.

It contains **home-manager**, **nixOS** and **nix-darwin** configuration
for several machines and VMs I use.

## First run

```bash
sh <(curl -L https://nixos.org/nix/install)
echo "experimental-features = nix-command flakes">~/.config/nix/nix.conf
```

On macOS, install homebrew too:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Also make sure the terminal being used has full disk access, otherwise you might
get errors like `Could not write domain`.

## Updating

To apply updates, simply run:

```bash
nix develop -c dot-apply

# pull, update flake, clean old, apply
nix develop -c dot-sync
```

## Clean up

```bash
nix develop -c dot-clean
```

# Create release

To create a release, run:

```bash
nix develop -c dot-release
```

## Post first run

### Fish as the default shell

```bash
which fish | sudo tee -a /etc/shells
chsh -s $(which fish)
```

### Keyboard layouts

Add the US layout so input doesn't wait after opening quotes and such.
