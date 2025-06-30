# 🏠 Hybrid Dotfiles Setup

This dotfiles repository supports both **Nix** and **system** installation methods, following DRY (Don't Repeat Yourself) principles for maximum reusability.

## 🏗️ Architecture Overview

```
dotfiles/
├── 📁 config/                    # Shared configurations (DRY principle)
│   ├── 📁 git/                   # Git configs (gitconfig.template, gitignore_global)
│   ├── 📁 shell/                 # Shell configs (aliases.sh, exports.sh)
│   ├── 📁 nvim/                  # Neovim configuration
│   ├── 📁 tmux/                  # Tmux configuration
│   └── 📁 tools/                 # Tool-specific configs
├── 📁 nix/                       # Nix-specific files (current modules/, flake.nix)
├── 📁 system/               # Traditional installation support
│   ├── 📁 installers/            # Package installation scripts
│   └── 📁 symlinks/              # Symlink creation scripts
├── 📁 scripts/                   # Management and utility scripts
└── 📄 install.sh                 # Main entry point
```

## 🚀 Quick Start

### Automatic Installation (Recommended)

```bash
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The script will:
1. **Detect your environment** (OS, package managers, existing tools)
2. **Recommend the best method** (Nix vs system)
3. **Install packages and configure** your development environment
4. **Create necessary symlinks** and configurations

### Manual Method Selection

```bash
# Force Nix installation
./install.sh --method nix

# Force system installation
./install.sh --method system

# Preview what would be installed
./install.sh --dry-run

# Force reinstall
./install.sh --force --method nix
```

## 📖 Installation Methods

### 🔷 Nix Method (Recommended)

**When to use:**
- You want reproducible, declarative configurations
- You're on NixOS or already have Nix installed
- You want isolated environments and rollback capabilities

**What it provides:**
- **Package Management:** All tools managed by Nix
- **Configuration Management:** Home Manager handles dotfiles
- **Reproducibility:** Same environment across machines
- **Rollback:** Easy to revert changes

**Requirements:**
- Nix package manager (auto-installed if missing)
- Home Manager (auto-installed if missing)

### 🔶 Traditional Method

**When to use:**
- You prefer system package managers (brew, apt, etc.)
- You're on a system where Nix isn't suitable
- You want more manual control over installations

**What it provides:**
- **Package Management:** Uses system package managers
- **Configuration Management:** Manual symlinks and shell sourcing
- **Flexibility:** Easy to customize and modify
- **Compatibility:** Works on any Unix-like system

**Requirements:**
- System package manager (brew, apt, pacman, etc.)
- Standard Unix tools (bash, git, curl)

## 🔧 Shared Configurations (DRY Principle)

All configurations are stored in the `config/` directory and shared between both methods:

### Shell Configuration
- **`config/shell/aliases.sh`** - Common aliases for all shells
- **`config/shell/exports.sh`** - Environment variables and PATH setup

### Tool Configurations
- **`config/git/gitconfig.template`** - Git configuration template
- **`config/git/gitignore_global`** - Global gitignore patterns
- **`config/tmux/tmux.conf`** - Tmux configuration
- **`config/nvim/`** - Neovim configuration

### How It Works

**Nix Method:** Configurations are imported into Nix modules
```nix
# modules/git/default.nix
{ config, ... }: {
  programs.git = {
    extraConfig = builtins.readFile ../../config/git/gitconfig.template;
  };
}
```

**Traditional Method:** Configurations are symlinked or sourced
```bash
# ~/.bashrc
source ~/.dotfiles/config/shell/aliases.sh
source ~/.dotfiles/config/shell/exports.sh
```

## 🛠️ Environment Detection

The `scripts/detect-env.sh` script automatically detects:

- **Operating System** (macOS, Linux distributions, WSL)
- **Package Managers** (Nix, Homebrew, APT, Pacman, DNF, etc.)
- **Existing Tools** (Git, Neovim, development tools, modern CLI tools)
- **Current Configuration** (Home Manager availability, shell type)

Based on this detection, it recommends the optimal installation method.

## 📁 Directory Structure Details

### `config/` - Shared Configurations
Contains all tool configurations in their raw form, designed to be:
- **Portable** - Work across different systems
- **Customizable** - Easy to modify and extend
- **Template-based** - Use variables for user-specific values

### `nix/` - Nix-Specific Files
- **`flake.nix`** - Main Nix flake configuration
- **`modules/`** - Home Manager modules
- **`machines/`** - Machine-specific configurations
- **`pkgs/`** - Custom package definitions

### `system/` - Traditional Setup
- **`installers/`** - Package installation scripts for different systems
- **`symlinks/`** - Symlink creation and management scripts

### `scripts/` - Utility Scripts
- **`detect-env.sh`** - Environment detection
- **`install-nix.sh`** - Nix installation helper
- **`install-system.sh`** - Traditional installation helper
- **`create-symlinks.sh`** - Symlink management

## 🔄 Switching Between Methods

You can switch between Nix and system methods:

```bash
# Switch to Nix (if you were using system)
./install.sh --method nix --force

# Switch to system (if you were using Nix)
./install.sh --method system --force
```

**Note:** The `--force` flag will backup existing configurations before switching.

## 🧪 Testing and Validation

### Test Installation
```bash
# Preview installation without making changes
./install.sh --dry-run

# Test environment detection
./scripts/detect-env.sh

# Validate configurations
./scripts/validate-configs.sh
```

### Verify Setup
```bash
# Check that tools are available
which git nvim tmux fish

# Verify configurations are loaded
alias ll  # Should show custom alias
echo $EDITOR  # Should show nvim
```

## 🎯 Best Practices

### Adding New Tools

1. **Add to shared config:** Create configuration in `config/`
2. **Update Nix modules:** Import config in appropriate `modules/` file
3. **Update system scripts:** Add to installation scripts
4. **Test both methods:** Ensure it works in both Nix and system setups

### Modifying Configurations

1. **Edit shared files:** Modify files in `config/` directory
2. **Use templates:** For user-specific values, use template variables
3. **Test changes:** Use `--dry-run` to preview changes
4. **Commit changes:** Follow git best practices

### Platform Support

The dotfiles automatically detect and adapt to:
- **macOS** (Darwin)
- **Linux** (Ubuntu, Arch, Fedora, etc.)
- **WSL** (Windows Subsystem for Linux)

## 🔍 Troubleshooting

### Common Issues

1. **Nix not found:** Run `./install.sh --method system` first
2. **Permission errors:** Ensure scripts are executable (`chmod +x`)
3. **Config conflicts:** Use `--force` to backup and overwrite
4. **Missing tools:** Check environment detection output

### Getting Help

```bash
# Show installation help
./install.sh --help

# Check environment status
./scripts/detect-env.sh

# View logs
tail -f ~/.dotfiles/install.log
```

## 🎉 Benefits of This Approach

1. **Flexibility:** Choose your preferred installation method
2. **Portability:** Same configurations work everywhere
3. **Maintainability:** DRY principle reduces duplication
4. **Reliability:** Automatic detection prevents errors
5. **Scalability:** Easy to add new tools and configurations

This hybrid approach gives you the best of both worlds: the power and reproducibility of Nix when you want it, and the simplicity and familiarity of system methods when you need it.