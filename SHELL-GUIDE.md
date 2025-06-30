# 🐚 Shell Configuration Guide

This guide explains how the hybrid dotfiles handle shell selection and configuration.

## Quick Start

```bash
# Auto-detect and install (recommends Fish if available)
./install.sh

# Force specific shell
./install.sh --shell fish
./install.sh --shell bash

# Preview what would happen
./install.sh --dry-run
```

## Shell Priority

1. **Fish (Preferred)**: Modern shell with autosuggestions, syntax highlighting
2. **Bash (Fallback)**: Universal compatibility, enhanced with custom functions

## Environment Detection

The system automatically detects:
- Available shells on your system
- Whether Fish can be installed
- Platform-specific constraints
- Package manager capabilities

## Configuration Structure

```
config/
├── fish/
│   └── config.fish          # Native Fish configuration
├── bash/
│   └── bashrc              # Enhanced Bash fallback
└── shell/
    ├── aliases.sh          # Bash/Zsh compatible aliases
    ├── aliases.fish        # Fish compatible aliases
    ├── exports.sh          # Bash/Zsh environment variables
    └── exports.fish        # Fish environment variables
```

## Switching Shells

### To Fish (from Bash)
```bash
# Install Fish if not available
# Ubuntu/Debian: sudo apt install fish
# macOS: brew install fish
# Arch: sudo pacman -S fish

# Set as default shell
chsh -s $(which fish)

# Start Fish session
exec fish
```

### To Bash (from Fish)
```bash
# Temporary switch
exec bash

# Change default shell
chsh -s $(which bash)
```

## Customization

### Local Overrides
Create local configuration files that won't be tracked:
- `~/.localrc` (for Bash/Zsh)
- `~/.localrc.fish` (for Fish)

### Adding New Aliases
1. **Shared aliases**: Add to `config/shell/aliases.sh` and `config/shell/aliases.fish`
2. **Shell-specific**: Add to respective shell config files

## Troubleshooting

### Fish Not Available
- Check if Fish is installed: `which fish`
- Install via package manager
- Re-run installation: `./install.sh`

### Configuration Not Loading
- Check shell integration: `echo $SHELL`
- Reload configuration: `source ~/.bashrc` or `exec fish`
- Verify symlinks: `ls -la ~/.config/fish/config.fish`

## Advanced Usage

### Multiple Environments
The dotfiles adapt automatically:
- **Development machines**: Full Fish configuration
- **Servers**: Minimal Bash fallback
- **Containers**: Environment-appropriate selection

### Nix Integration
When using Nix:
- Fish is preferred and automatically configured
- Home Manager handles shell setup
- Shared configurations still apply