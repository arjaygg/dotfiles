# Traditional Setup Integration

This document describes how to use the traditional (non-Nix) setup that has been integrated from the [arjaygg/dotfiles_old](https://github.com/arjaygg/dotfiles_old/tree/feature/Ubutuntu22.04.2) repository.

## Overview

The traditional setup provides an alternative installation method that uses system package managers directly instead of Nix. This is useful for:

- Quick setup on systems without Nix
- Testing configurations before committing to Nix setup
- Systems where Nix installation is not feasible
- Ubuntu 22.04.2 specific configurations

## Installation

### Quick Start

To install the traditional setup with all configurations:

```bash
./scripts/install-traditional.sh
```

The script will auto-detect your package manager (apt, brew, pacman) and install accordingly.

### Manual Package Manager Selection

If you want to force a specific package manager:

```bash
./scripts/install-traditional.sh --apt     # For Ubuntu/Debian
./scripts/install-traditional.sh --brew    # For macOS
./scripts/install-traditional.sh --pacman  # For Arch Linux
./scripts/install-traditional.sh --generic # Fallback method
```

## What Gets Installed

### System Tools
- **Modern CLI tools**: `bat`, `exa`, `fd`, `ripgrep`, `fzf`
- **Development tools**: `git`, `curl`, `fish`, `starship`
- **Programming languages**: Go, Rust, Node.js, Python
- **Utilities**: `htop`, `tree`, `jq`, `yq`

### Applications
- **Alacritty**: Modern terminal emulator with Catppuccin theme
- **i3 Window Manager**: Tiling window manager (Linux only)
- **Neovim**: Modern text editor

### Configurations
- i3 window manager configuration with custom keybindings
- Alacritty terminal configuration
- Fish shell functions and abbreviations
- System tool configurations and aliases

## Directory Structure

```
traditional/
├── alacritty/          # Alacritty terminal configuration
│   ├── alacritty.yml   # Terminal config file
│   └── install.sh      # Installation script
├── i3/                 # i3 window manager configuration
│   ├── i3config        # i3 configuration file
│   └── install.sh      # Installation script
└── system/             # System tools and shell configuration
    ├── functions/      # Fish shell functions
    ├── conf.d/         # Fish configuration files
    ├── bat.config      # bat configuration
    ├── install.fish    # Fish-based installer
    └── install.sh      # Bash-based installer
```

## Individual Component Installation

You can install individual components by running their specific installation scripts:

### i3 Window Manager (Linux only)
```bash
./traditional/i3/install.sh
```

This installs:
- i3 window manager and related tools
- Custom keybindings configuration
- Desktop environment integration

### Alacritty Terminal
```bash
./traditional/alacritty/install.sh
```

This installs:
- Alacritty terminal emulator
- Custom configuration with Catppuccin theme
- Font and appearance settings

### System Tools
```bash
./traditional/system/install.sh
```

This installs:
- Modern CLI tools with proper symlinks
- Fish shell configuration
- System utilities and aliases

## Key Features from Target Repository

### i3 Window Manager Configuration
- **Mod key**: Super/Windows key
- **Terminal**: Alacritty (`Mod+Return`)
- **Application launcher**: Rofi (`Mod+d`)
- **Window management**: Vim-like navigation (`Mod+hjkl`)
- **Workspaces**: 10 workspaces with easy switching
- **Media controls**: Volume, brightness, media player controls
- **Custom features**: Workspace movement, floating toggles, layout management

### Shell Enhancements
- **Fish shell**: Modern shell with syntax highlighting
- **Abbreviations**: Quick command shortcuts
- **Functions**: Custom utility functions
- **Tool integration**: bat, exa, fd, fzf, zoxide integration

### Terminal Configuration
- **Font**: JetBrains Mono Nerd Font
- **Theme**: Catppuccin Mocha color scheme
- **Performance**: GPU acceleration enabled
- **Customization**: Transparent background, custom key bindings

## Post-Installation Steps

### For i3 Users (Linux)
1. Log out of your current session
2. At the login screen, select "i3" as your session type
3. Log in to start using the i3 window manager
4. Configure additional tools:
   - Install and configure polybar for status bar
   - Install and configure rofi themes
   - Add wallpapers to `~/Pictures/wallpapers/`

### Shell Configuration
1. Restart your terminal or run: `source ~/.bashrc`
2. If using Fish shell, run: `fish` to switch to Fish
3. Install additional Fish plugins as needed

### Customization
- Configuration files are located in `~/.config/`
- Modify `~/.config/i3/config` for i3 customizations
- Modify `~/.config/alacritty/alacritty.yml` for terminal customizations
- Add custom Fish functions to `~/.config/fish/functions/`

## Troubleshooting

### Common Issues

**i3 won't start**
- Ensure all dependencies are installed: `picom`, `dunst`, `feh`, `rofi`
- Check i3 configuration: `i3 -C ~/.config/i3/config`

**Alacritty font issues**
- Install JetBrains Mono Nerd Font manually
- Update font cache: `fc-cache -fv`

**Shell integration not working**
- Ensure `~/.bin` is in your PATH
- Check symlinks: `ls -la ~/.bin/`
- Restart shell or source configuration files

### Getting Help

If you encounter issues:
1. Check the installation logs for error messages
2. Verify all dependencies are installed
3. Compare with the original repository configurations
4. Consider using the Nix setup as an alternative

## Migration to Nix

Once you've tested the traditional setup and are satisfied with the configurations, you can migrate to the Nix-based setup for better reproducibility and management:

```bash
# Use the existing Nix setup
nix run .#homeConfigurations.$(whoami).activationPackage
```

The Nix setup provides the same functionality with better:
- **Reproducibility**: Exact package versions
- **Rollback capability**: Easy to revert changes
- **Cross-platform consistency**: Same setup across different systems
- **Declarative configuration**: Everything defined in code