# Traditional Self-Maintaining Setup

This document describes the traditional (non-Nix) setup with complete automation capabilities. The system maintains itself with minimal manual intervention.

## Overview

The traditional setup provides a fully automated dotfiles system that:

- **Self-maintains**: Automatically updates tools and configurations
- **Cross-platform**: Works on macOS, Linux, and WSL
- **Zero-config**: Minimal setup, maximum automation
- **Fail-safe**: Automatic backups and rollback capabilities
- **Monitored**: Health checks and comprehensive logging

Perfect for:
- Development teams needing standardized environments
- Personal use with zero maintenance overhead
- Systems where you want modern tools without package manager complexity
- Quick onboarding of new machines

## Installation

### 🚀 Automated Installation (Recommended)

Complete setup with automation in 2 minutes:

```bash
# Clone repository
git clone https://github.com/arjaygg/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Install everything with automation
./scripts/install-traditional.sh

# Enable daily automated maintenance
dotfiles schedule daily

# Verify installation
dotfiles status
```

### Manual Installation Options

Force a specific package manager:

```bash
./scripts/install-traditional.sh --apt     # For Ubuntu/Debian
./scripts/install-traditional.sh --brew    # For macOS
./scripts/install-traditional.sh --pacman  # For Arch Linux
./scripts/install-traditional.sh --generic # Fallback method
```

### Custom Installation

```bash
# Install configurations only (skip tool installation)
./scripts/install-traditional.sh --skip-tools

# Manual automation setup after installation
dotfiles schedule daily    # Daily tool updates
dotfiles schedule weekly   # Weekly config sync
dotfiles schedule monthly  # Monthly full maintenance
```

## What Gets Installed

### 🛠️ Modern Development Tools
- **Modern CLI**: `bat`, `eza`, `fd`, `ripgrep`, `fzf`, `starship`
- **Git Workflow**: `git`, `gh` (GitHub CLI), `lazygit`, `delta`
- **Development**: `nvim`, `tmux`, `curl`, `jq`, `yq`
- **Languages**: Go, Rust (with cargo), Node.js (with npm), Python
- **Cloud/DevOps**: `kubectl`, container tools

### 🖥️ Applications & Configurations
- **Alacritty**: Modern terminal with optimized themes
- **i3 Window Manager**: Productivity-focused tiling (Linux)
- **Fish Shell**: Modern shell with intelligent completions
- **Neovim**: Extensible editor with modern plugins

### 🤖 Automation System
- **Command Interface**: Global `dotfiles` command for all operations
- **Auto-Updates**: Daily tool updates, weekly config sync
- **Health Monitoring**: Automatic issue detection and resolution
- **Backup System**: Automatic backups before any changes
- **Cross-Platform**: Consistent behavior across macOS/Linux/WSL

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

## 🤖 Automation Features

### Daily Usage (Zero Maintenance!)

After installation, your system maintains itself:

```bash
# Check overall system status
dotfiles status

# View recent activity  
tail -20 ~/.dotfiles-update.log

# Manual operations (run automatically)
dotfiles sync      # Weekly - sync configs
dotfiles update    # Daily - update tools
dotfiles health    # Continuous - check health
```

### Automated Maintenance Schedule

| Frequency | Operations | Command |
|-----------|------------|---------|
| **Daily** | Tool updates, plugin updates, cleanup | `auto-update.sh` |
| **Weekly** | Config sync, repository updates | `dotfiles-sync.sh` |
| **Monthly** | Full system maintenance | `auto-update.sh` (full) |

### Backup & Recovery

**Automatic Backups**:
- Created before every change
- Stored in `~/.dotfiles-backups/`
- Automatic cleanup (keeps last 5)
- Easy restoration

```bash
# Manage backups
dotfiles backup list      # List available backups
dotfiles backup create    # Create manual backup
dotfiles backup clean     # Clean old backups

# Restore manually if needed
ls ~/.dotfiles-backups/
cp -r ~/.dotfiles-backups/20240630_120000/.bashrc ~/
```

### Health Monitoring

The system continuously monitors:
- **Tool availability** and versions
- **Configuration integrity** (symlinks, syntax)
- **Repository status** (updates, conflicts)
- **System health** (permissions, dependencies)

```bash
# Health commands
dotfiles health     # Quick health check
dotfiles doctor     # Comprehensive diagnosis
dotfiles status     # Full system status
```

## Post-Installation Steps

### 🐚 Shell Setup
1. **Automatic**: Shell configuration applied during installation
2. **Fish Shell**: Restart terminal to activate Fish features
3. **Customization**: Add personal functions to `~/.config/fish/functions/`

### 🖥️ Desktop Environment (Linux)
1. **i3 Window Manager**: 
   - Log out and select "i3" at login screen
   - Automatic configuration applied
   - Keybindings ready to use (`Mod+Return` for terminal)

2. **Terminal Setup**:
   - Alacritty configured with modern theme
   - Font and color schemes optimized
   - GPU acceleration enabled

### 🎨 Customization Points

| Component | Configuration Location | Purpose |
|-----------|----------------------|---------|
| **Shell** | `~/.config/fish/config.fish` | Fish shell settings |
| **Terminal** | `~/.config/alacritty/alacritty.yml` | Terminal appearance |
| **Editor** | `~/.config/nvim/` | Neovim configuration |
| **Git** | `~/.gitconfig` | Git aliases and settings |
| **i3** | `~/.config/i3/config` | Window manager |

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