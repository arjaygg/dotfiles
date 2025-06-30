# 🏠 Self-Maintaining Dotfiles

A modern, automated dotfiles system that **maintains itself** with minimal manual intervention.

Originally based on caarlos0/dotfiles, now enhanced with:
- **🤖 Complete Automation**: Self-updating tools and configurations
- **🔄 Smart Sync**: Automatic repository updates and conflict resolution  
- **🐚 Intelligent Shell Setup**: Fish preferred with Bash fallback
- **🌍 Cross-Platform**: macOS, Linux, WSL compatibility
- **💾 Auto-Backup**: Automatic backups before any changes
- **🏥 Health Monitoring**: Self-diagnosis and healing

## 📚 Documentation

| Guide | Description |
|-------|-------------|
| **[Quick Start](#-quick-start)** | Get up and running in 2 minutes |
| **[Automation Guide](AUTOMATION.md)** | Complete automation features |
| **[System Architecture](ARCHITECTURE.md)** | How everything works |
| **[System Setup](SYSTEM-SETUP.md)** | System installation details |
| **[Shell Guide](SHELL-GUIDE.md)** | Shell configuration details |

## ⚡ Quick Start

### 🚀 New Installation (2 minutes)
```bash
# Clone and install with full automation
git clone https://github.com/arjaygg/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./scripts/install-system.sh

# Setup automated maintenance
dotfiles schedule daily

# Verify everything works
dotfiles status
```

### 🔄 Daily Usage (Zero maintenance required!)
```bash
# Check status and health
dotfiles status

# Manual sync (runs automatically weekly)
dotfiles sync

# Manual updates (runs automatically daily)  
dotfiles update

# Get help
dotfiles help
```

## 🎯 What You Get

### **Automated Tools Installation**
- **Modern CLI**: `bat`, `eza`, `fd`, `ripgrep`, `fzf`, `starship`
- **Development**: `git`, `gh`, `lazygit`, `nvim`, `tmux`
- **Languages**: Go, Rust, Node.js, Python with toolchains
- **Cloud/DevOps**: `kubectl`, `docker`, `curl`, `jq`

### **Self-Maintaining System**
- **Daily Updates**: All tools stay current automatically
- **Weekly Sync**: Repository and configurations sync
- **Auto-Backup**: Before every change, keeps last 5
- **Health Checks**: Detects and fixes issues automatically
- **Smart Conflicts**: Auto-resolves with fallbacks

### **Zero-Config Management**
- **Single Command**: `dotfiles <action>` for everything
- **Automatic Symlinks**: All configs linked and maintained
- **Cross-Platform**: Same commands work everywhere
- **Comprehensive Logging**: Track all changes and updates

## 🛠️ Available Commands

### Essential Commands
```bash
dotfiles status      # Show comprehensive system status
dotfiles sync        # Sync latest configurations  
dotfiles update      # Update all tools and packages
dotfiles health      # Run health checks and diagnostics
dotfiles help        # Show all available commands
```

### Maintenance Commands  
```bash
dotfiles schedule    # Setup automated maintenance
dotfiles backup      # Manage configuration backups
dotfiles clean       # Clean old files and caches
dotfiles doctor      # Diagnose and fix issues
dotfiles install     # Fresh install on new system
```

## 🔧 Installation Options

### **Recommended: Full Automation**
```bash
./scripts/install-system.sh        # Auto-detect and install everything
dotfiles schedule daily                 # Enable daily automation
```

### **Manual Package Manager Selection**
```bash
./scripts/install-system.sh --apt     # Ubuntu/Debian
./scripts/install-system.sh --brew    # macOS  
./scripts/install-system.sh --pacman  # Arch Linux
./scripts/install-system.sh --generic # Fallback method
```

### **Custom Installation**
```bash
./scripts/install-system.sh --skip-tools    # Install configs only
dotfiles sync --no-backup                        # Skip backups
dotfiles update --skip-system                    # Skip system packages
```

## 📊 System Status

After installation, check your system:

```bash
$ dotfiles status

📊 Dotfiles Status

📁 Repository:
   Path: /home/user/.dotfiles
   Branch: main  
   Status: 0 uncommitted changes
   Last update: 2 hours ago

🛠️  Tools:
   ✅ git (2.40.1)
   ✅ fish (3.6.1)  
   ✅ nvim (0.9.1)
   ✅ bat (0.23.0)
   ✅ eza (0.10.5)
   ✅ fd (8.7.0)
   ✅ rg (13.0.0)
   ✅ fzf (0.42.0)
   ✅ gh (2.32.1)
   ✅ lazygit (0.40.2)

💾 Backups: 3 available, latest: 20240630_120000
🏥 Health: All checks passed
```

## 🤖 Automation Features

Your dotfiles will automatically:

✅ **Update tools daily** (Rust, Node.js, Go, Python, CLI tools)  
✅ **Sync configurations weekly** (pull latest, update symlinks)  
✅ **Create backups** before any changes  
✅ **Monitor health** and fix issues  
✅ **Clean up** old files and caches  
✅ **Log everything** for transparency  

### Scheduling Options
```bash
dotfiles schedule daily     # Recommended: daily tool updates
dotfiles schedule weekly    # Weekly updates only  
dotfiles schedule monthly   # Monthly full maintenance
```

## 🔗 Integration

### Shell Integration
The system automatically configures:
- **Fish shell** with modern features and functions
- **Bash fallback** with same aliases and exports  
- **Starship prompt** for consistent experience
- **Tool integrations** (fzf, zoxide, etc.)

### Tool Configurations
Auto-managed configurations for:
- **Git**: Aliases, delta integration, global ignore
- **Neovim**: Modern setup with plugins (if configured)
- **Tmux**: Productivity-focused configuration  
- **Alacritty**: Modern terminal with themes
- **i3**: Tiling window manager setup (Linux)

## 🚨 Troubleshooting

### Quick Fixes
```bash
# Fix common issues
dotfiles doctor

# Force sync everything  
dotfiles sync --force

# Reinstall missing tools
dotfiles install

# Check logs
tail -20 ~/.dotfiles-update.log
```

### Common Issues
- **Command not found**: Restart shell or run `source ~/.bashrc`
- **Symlink issues**: Run `dotfiles sync --force`
- **Update failures**: Check `dotfiles doctor` output
- **Permission errors**: Ensure scripts are executable

## 📂 Repository Structure

```
~/.dotfiles/
├── 📁 config/           # Core configurations
│   ├── bash/            # Bash shell setup
│   ├── fish/            # Fish shell setup  
│   ├── git/             # Git configuration
│   ├── nvim/            # Neovim setup
│   ├── shell/           # Shared shell configs
│   └── tmux/            # Tmux configuration
├── 📁 scripts/          # Automation scripts
│   ├── dotfiles.sh      # Main CLI interface
│   ├── dotfiles-sync.sh # Sync automation
│   ├── auto-update.sh   # Update automation
│   └── install-system.sh
├── 📁 traditional/      # Platform-specific configs
│   ├── alacritty/       # Terminal emulator
│   ├── i3/              # Window manager  
│   └── system/          # System tools
└── 📄 docs/             # Documentation
    ├── AUTOMATION.md    # Automation guide
    ├── ARCHITECTURE.md  # System architecture
    └── TRADITIONAL-SETUP.md
```

## 🌟 Why This Dotfiles System?

### **For Developers**
- **Zero maintenance**: Focuses on coding, not config management
- **Always current**: Latest tools and security updates
- **Consistent environment**: Same setup across all machines
- **Fast onboarding**: New machine ready in 2 minutes

### **For Teams**  
- **Standardized tooling**: Everyone uses same modern tools
- **Easy sharing**: Clone and run, everything works
- **Documentation**: Comprehensive guides and help
- **Flexible**: Supports different platforms and preferences

### **For DevOps**
- **Infrastructure as Code**: Dotfiles managed like infrastructure
- **Automated maintenance**: No manual intervention required
- **Monitoring**: Health checks and logging built-in
- **Recovery**: Automatic backups and rollback capability

## 🎉 Getting Started

Ready to automate your development environment?

1. **Install**: `git clone https://github.com/arjaygg/dotfiles.git ~/.dotfiles && cd ~/.dotfiles && ./scripts/install-system.sh`

2. **Automate**: `dotfiles schedule daily`

3. **Enjoy**: Your dotfiles now maintain themselves!

For questions or issues, check the [documentation](AUTOMATION.md) or run `dotfiles doctor`.

---

*Originally based on [caarlos0/dotfiles](https://github.com/caarlos0/dotfiles.fish) • Enhanced with modern automation*