# 🤖 Dotfiles Automation Guide

This guide covers the automated maintenance features of your dotfiles system, designed to minimize manual work and keep everything up-to-date.

## 🎯 Overview

Your dotfiles now include a comprehensive automation system that handles:
- **Automatic syncing** of configurations
- **Tool updates** and maintenance
- **Backup management** 
- **Health monitoring**
- **Symlink management**

## 🚀 Quick Start

### Install and Setup
```bash
# Install dotfiles with automation
./scripts/install-system.sh

# Setup automated maintenance (daily updates)
dotfiles schedule daily

# Check everything is working
dotfiles status
```

### Daily Usage
```bash
# Sync latest changes from repository
dotfiles sync

# Update all tools and packages
dotfiles update

# Check system health
dotfiles health

# Show current status
dotfiles status
```

## 📋 Commands Reference

### Main Commands
| Command | Description | Example |
|---------|-------------|---------|
| `dotfiles sync` | Sync configurations and repository | `dotfiles sync --force` |
| `dotfiles update` | Update all tools and packages | `dotfiles update --skip-system` |
| `dotfiles install` | Fresh installation on new system | `dotfiles install` |
| `dotfiles status` | Show comprehensive status | `dotfiles status` |
| `dotfiles health` | Run health checks | `dotfiles health` |

### Maintenance Commands
| Command | Description | Example |
|---------|-------------|---------|
| `dotfiles schedule` | Setup automated maintenance | `dotfiles schedule weekly` |
| `dotfiles backup` | Manage backups | `dotfiles backup create` |
| `dotfiles clean` | Clean old files and caches | `dotfiles clean` |
| `dotfiles doctor` | Diagnose and fix issues | `dotfiles doctor` |

## ⏰ Automated Scheduling

### Setup Options
```bash
# Daily tool updates (recommended)
dotfiles schedule daily

# Weekly full maintenance
dotfiles schedule weekly  

# Monthly comprehensive updates
dotfiles schedule monthly
```

### What Gets Scheduled
- **Daily**: Tool updates, plugin updates, cache cleanup
- **Weekly**: Repository sync, configuration updates
- **Monthly**: Full system update, backup cleanup

### Manual Cron Setup
If you prefer manual control:
```bash
# Edit crontab
crontab -e

# Add these lines:
0 9 * * * ~/.dotfiles/scripts/auto-update.sh --skip-system >> ~/.dotfiles-update.log 2>&1
0 10 * * 0 ~/.dotfiles/scripts/dotfiles-sync.sh >> ~/.dotfiles-update.log 2>&1
```

## 🔄 Sync System

### What Gets Synced
- **Repository updates** from remote
- **Configuration symlinks**
- **Tool installations**
- **Shell integrations**

### Sync Options
```bash
# Standard sync
dotfiles sync

# Force sync (overwrite conflicts)
dotfiles sync --force

# Sync without backup
dotfiles sync --no-backup

# Skip tool updates
dotfiles sync --skip-tools

# Health check only
dotfiles sync --health-check-only
```

### Conflict Resolution
When conflicts occur:
1. **Automatic backup** of existing files
2. **Stash uncommitted** git changes
3. **Create symlinks** to dotfiles
4. **Report any issues** for manual review

## 🔧 Update System

### What Gets Updated
- **System packages** (apt/brew/pacman)
- **Development tools** (Rust, Node.js, Go, Python)
- **Manual installations** (starship, eza, lazygit)
- **Editor plugins** (Neovim)
- **CLI extensions** (GitHub CLI)

### Update Categories
```bash
# Update everything
dotfiles update

# Skip system packages
dotfiles update --skip-system

# Skip development tools
dotfiles update --skip-tools

# Cleanup only
dotfiles update --cleanup-only
```

### Tool-Specific Updates
- **Rust**: `rustup update` + `cargo install-update -a`
- **Node.js**: `npm update -g` + `fnm install --lts`
- **Go**: Update common tools (`gopls`, `golangci-lint`, etc.)
- **Python**: `pip3 upgrade` + `poetry self update`
- **Manual tools**: Check GitHub releases for updates

## 💾 Backup System

### Automatic Backups
- **Before sync**: Current configurations backed up
- **Before updates**: System state captured
- **Scheduled cleanup**: Keep last 5 backups

### Backup Management
```bash
# List available backups
dotfiles backup list

# Create manual backup
dotfiles backup create

# Clean old backups
dotfiles backup clean

# Restore from backup (manual process)
ls ~/.dotfiles-backups/
cp -r ~/.dotfiles-backups/20240630_120000/.bashrc ~/
```

### Backup Locations
- **Configurations**: `~/.dotfiles-backups/YYYYMMDD_HHMMSS/`
- **Logs**: `~/.dotfiles-update.log`
- **Git stash**: For uncommitted repository changes

## 🏥 Health Monitoring

### Health Checks
- **Symlink integrity** - All configs properly linked
- **Tool availability** - Essential tools installed
- **Repository status** - Git repo healthy
- **Configuration validity** - Configs syntactically correct

### Health Commands
```bash
# Quick health check
dotfiles health

# Comprehensive diagnosis
dotfiles doctor

# Show detailed status
dotfiles status
```

### Common Issues & Fixes
| Issue | Automatic Fix | Manual Action |
|-------|---------------|---------------|
| Broken symlinks | ✅ Recreated | `dotfiles sync --force` |
| Missing tools | ✅ Reinstalled | `dotfiles install` |
| Git conflicts | ✅ Auto-stash | Resolve manually |
| Permission errors | ✅ Fixed | `chmod +x scripts/*` |

## 🔗 Symlink Management

### Automatic Symlinks
The system automatically manages symlinks for:
- Shell configurations (`.bashrc`, `config.fish`)
- Tool configurations (`.gitconfig`, `.tmux.conf`)
- Application configs (Alacritty, i3, Neovim)

### Manual Symlink Control
```bash
# View symlink status
./scripts/create-symlinks.sh --help

# Force recreate all symlinks
./scripts/create-symlinks.sh --force

# Verify symlink integrity
./scripts/dotfiles-sync.sh --health-check-only
```

## 📊 Monitoring & Logs

### Log Files
- **Main log**: `~/.dotfiles-update.log`
- **Git logs**: View with `dotfiles status`
- **System logs**: Platform-specific package manager logs

### Status Information
```bash
# Comprehensive status
dotfiles status

# Recent activity
tail -20 ~/.dotfiles-update.log

# Git history
cd ~/.dotfiles && git log --oneline -10
```

## 🛠️ Customization

### Configuration File
Create `~/.dotfiles.conf` for custom settings:
```bash
# Update frequency
AUTO_UPDATE_FREQUENCY=daily

# Backup retention
BACKUP_RETENTION_DAYS=30

# Skip certain updates
SKIP_SYSTEM_UPDATES=false
SKIP_RUST_UPDATES=false
```

### Adding Custom Tools
Edit `scripts/auto-update.sh` to add your tools:
```bash
# Add to update_custom_tools() function
update_my_tool() {
    if command -v mytool >/dev/null 2>&1; then
        mytool --update
        log_success "My tool updated"
    fi
}
```

### Custom Symlinks
Edit `scripts/create-symlinks.sh`:
```bash
# Add to SYMLINK_MAP
["my-config/myapp.conf"]="$HOME/.config/myapp/config"
```

## 🚨 Troubleshooting

### Common Problems

**Q: Automation not running**
```bash
# Check cron jobs
crontab -l

# Check logs
tail ~/.dotfiles-update.log

# Re-setup
dotfiles schedule daily
```

**Q: Symlinks broken**
```bash
# Fix all symlinks
dotfiles sync --force

# Check specific issues
dotfiles doctor
```

**Q: Updates failing**
```bash
# Check permissions
ls -la ~/.dotfiles/scripts/

# Fix permissions
chmod +x ~/.dotfiles/scripts/*.sh

# Manual update
dotfiles update --skip-system
```

**Q: Git conflicts**
```bash
# Check repository status
cd ~/.dotfiles && git status

# Resolve conflicts
cd ~/.dotfiles && git stash && git pull
```

### Getting Help
1. **Check logs**: `tail -50 ~/.dotfiles-update.log`
2. **Run doctor**: `dotfiles doctor`
3. **Check status**: `dotfiles status`
4. **Manual verification**: `./scripts/dotfiles-sync.sh --health-check-only`

## 🎉 Benefits

With this automation system, you get:

✅ **Zero-maintenance** dotfiles that stay current  
✅ **Automatic backups** before any changes  
✅ **Health monitoring** with self-healing  
✅ **Tool updates** without manual intervention  
✅ **Cross-system sync** for multiple machines  
✅ **Rollback capability** via backups  
✅ **Comprehensive logging** for transparency  

Your dotfiles now maintain themselves! 🚀