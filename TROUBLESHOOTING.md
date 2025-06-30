# 🔧 Troubleshooting Guide

This guide helps you diagnose and fix common issues with the self-maintaining dotfiles system.

## 🚀 Quick Diagnostics

### First Steps for Any Issue

```bash
# Run comprehensive diagnostics
dotfiles doctor

# Check system status
dotfiles status

# View recent logs
tail -50 ~/.dotfiles-update.log

# Force health check
dotfiles health
```

## 🔍 Common Issues & Solutions

### Installation Issues

#### **Issue**: `Command 'dotfiles' not found`

**Cause**: The dotfiles command wasn't properly installed or PATH not updated.

**Solutions**:
```bash
# Re-run the alias setup
~/.dotfiles/scripts/setup-dotfiles-alias.sh

# Manually add to PATH (temporary fix)
export PATH="$HOME/.local/bin:$PATH"

# Restart shell
exec $SHELL

# Or source your profile
source ~/.bashrc  # or ~/.zshrc
```

#### **Issue**: `Permission denied` during installation

**Cause**: Script permissions or sudo access issues.

**Solutions**:
```bash
# Fix script permissions
chmod +x ~/.dotfiles/scripts/*.sh

# Check sudo access
sudo echo "Sudo access OK"

# Run installation with proper permissions
cd ~/.dotfiles && ./scripts/install-traditional.sh
```

#### **Issue**: Package installation fails

**Cause**: Package manager issues or network problems.

**Solutions**:
```bash
# Update package manager
sudo apt update          # Ubuntu/Debian
brew update             # macOS
sudo pacman -Sy         # Arch

# Check network connectivity
ping -c 3 google.com

# Use specific package manager
./scripts/install-traditional.sh --apt    # Force APT
./scripts/install-traditional.sh --brew   # Force Homebrew

# Skip problematic tools
./scripts/install-traditional.sh --skip-tools
```

### Configuration Issues

#### **Issue**: Symlinks not working

**Cause**: Broken or missing symlinks, file conflicts.

**Solutions**:
```bash
# Check symlink status
dotfiles health

# Force recreate all symlinks  
dotfiles sync --force

# Manual symlink creation
~/.dotfiles/scripts/create-symlinks.sh --force

# Check specific symlink
ls -la ~/.bashrc
ls -la ~/.config/fish/config.fish
```

#### **Issue**: Configuration changes not taking effect

**Cause**: Configuration not loaded or symlinks pointing to wrong files.

**Solutions**:
```bash
# Reload shell configuration
source ~/.bashrc         # Bash
exec fish               # Fish

# Check configuration sources
echo $SHELL
which fish
which bash

# Verify symlink targets
readlink ~/.bashrc
readlink ~/.config/fish/config.fish

# Force sync configurations
dotfiles sync --force
```

#### **Issue**: Git configuration problems

**Cause**: Template not processed or git config corrupted.

**Solutions**:
```bash
# Check git configuration
git config --list --show-origin

# Reprocess git template
dotfiles sync

# Manual git setup
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Check git template
cat ~/.dotfiles/config/git/gitconfig.template
```

### Update & Sync Issues

#### **Issue**: `dotfiles update` fails

**Cause**: Network issues, package manager problems, or dependency conflicts.

**Solutions**:
```bash
# Check specific update components
dotfiles update --skip-system    # Skip system packages
dotfiles update --skip-tools     # Skip development tools

# Check network and permissions
curl -I https://github.com
sudo apt update 2>&1 | head -10

# Update manually by category
sudo apt upgrade                 # System packages
rustup update                   # Rust toolchain  
npm update -g                   # Node.js packages

# Check logs for specific errors
grep -i error ~/.dotfiles-update.log
```

#### **Issue**: Repository sync fails

**Cause**: Git conflicts, network issues, or repository problems.

**Solutions**:
```bash
# Check git repository status
cd ~/.dotfiles && git status

# Resolve git conflicts manually
cd ~/.dotfiles
git stash                       # Stash local changes
git pull origin main            # Pull latest changes
git stash pop                   # Restore local changes

# Reset to clean state (nuclear option)
cd ~/.dotfiles
git reset --hard origin/main

# Check remote connectivity
cd ~/.dotfiles && git remote -v
cd ~/.dotfiles && git fetch --dry-run
```

#### **Issue**: Automation not running

**Cause**: Cron not setup, scripts not executable, or cron service issues.

**Solutions**:
```bash
# Check cron jobs
crontab -l

# Re-setup automation
dotfiles schedule daily

# Check cron service
systemctl status cron          # Linux
sudo service cron status       # Some systems

# Test scripts manually
~/.dotfiles/scripts/auto-update.sh --skip-system
~/.dotfiles/scripts/dotfiles-sync.sh --health-check-only

# Check script permissions
ls -la ~/.dotfiles/scripts/
```

### Tool-Specific Issues

#### **Issue**: Fish shell not working

**Cause**: Fish not installed, not set as default, or configuration issues.

**Solutions**:
```bash
# Check fish installation
which fish
fish --version

# Set fish as default shell
chsh -s $(which fish)

# Test fish configuration
fish -c "echo 'Fish is working'"

# Check fish config
cat ~/.config/fish/config.fish

# Reload fish configuration
exec fish
```

#### **Issue**: Modern CLI tools not found

**Cause**: Tools not installed or not in PATH.

**Solutions**:
```bash
# Check tool availability
which bat eza fd rg fzf

# Check PATH
echo $PATH | tr ':' '\n'

# Reinstall missing tools
dotfiles install

# Add tools to PATH manually
export PATH="$HOME/.local/bin:$PATH"
export PATH="/usr/local/bin:$PATH"

# Check tool installation
apt list --installed | grep -E "(bat|fd|ripgrep)"
brew list | grep -E "(bat|eza|fd)"
```

#### **Issue**: Neovim configuration problems

**Cause**: Neovim not installed, plugin issues, or configuration errors.

**Solutions**:
```bash
# Check neovim installation
nvim --version

# Check neovim configuration
ls -la ~/.config/nvim/

# Test neovim startup
nvim --headless -c "lua print('Neovim OK')" -c "qa"

# Reset neovim configuration
mv ~/.config/nvim ~/.config/nvim.backup
dotfiles sync --force

# Check neovim logs
cat ~/.local/state/nvim/log
```

### Performance Issues

#### **Issue**: Slow startup or updates

**Cause**: Network latency, large repositories, or too many parallel operations.

**Solutions**:
```bash
# Check network speed
curl -o /dev/null -s -w "Download speed: %{speed_download} bytes/sec\n" http://www.google.com

# Check disk space
df -h ~
du -sh ~/.dotfiles-backups/

# Clean up old files
dotfiles clean

# Check system resources
htop
free -h

# Reduce parallelism (edit scripts to use fewer background jobs)
```

#### **Issue**: High disk usage

**Cause**: Too many backups, large git repository, or cache accumulation.

**Solutions**:
```bash
# Check backup usage
du -sh ~/.dotfiles-backups/

# Clean old backups
dotfiles backup clean

# Check git repository size
du -sh ~/.dotfiles/.git/

# Clean git repository
cd ~/.dotfiles && git gc --aggressive

# Clean package manager caches
sudo apt autoclean             # Ubuntu
brew cleanup                   # macOS
```

## 🩺 Advanced Diagnostics

### System Health Check Script

Create a comprehensive health check:

```bash
#!/bin/bash
# Advanced diagnostics

echo "=== DOTFILES HEALTH CHECK ==="

# Check repository
echo "Repository Status:"
cd ~/.dotfiles && git status --porcelain
echo "Last commit: $(cd ~/.dotfiles && git log -1 --format='%cr')"

# Check essential tools
echo -e "\nTool Availability:"
for tool in git fish nvim tmux bat eza fd rg fzf gh lazygit; do
    if command -v "$tool" >/dev/null 2>&1; then
        version=$(command "$tool" --version 2>/dev/null | head -1 || echo "unknown")
        echo "✅ $tool: $version"
    else
        echo "❌ $tool: not found"
    fi
done

# Check symlinks
echo -e "\nSymlink Status:"
declare -A symlinks=(
    ["~/.bashrc"]="~/.dotfiles/config/bash/bashrc"
    ["~/.config/fish/config.fish"]="~/.dotfiles/config/fish/config.fish"
    ["~/.gitconfig"]="processed template"
)

for target in "${!symlinks[@]}"; do
    expanded_target="${target/#\~/$HOME}"
    if [[ -L "$expanded_target" ]]; then
        link_target=$(readlink "$expanded_target")
        echo "✅ $target -> $link_target"
    elif [[ -f "$expanded_target" ]]; then
        echo "⚠️  $target exists but not symlinked"
    else
        echo "❌ $target missing"
    fi
done

# Check automation
echo -e "\nAutomation Status:"
if crontab -l 2>/dev/null | grep -q dotfiles; then
    echo "✅ Automation scheduled"
    crontab -l | grep dotfiles
else
    echo "❌ No automation scheduled"
fi

# Check recent activity
echo -e "\nRecent Activity:"
if [[ -f ~/.dotfiles-update.log ]]; then
    echo "Last 5 log entries:"
    tail -5 ~/.dotfiles-update.log
else
    echo "❌ No update log found"
fi

echo -e "\n=== END HEALTH CHECK ==="
```

### Log Analysis

```bash
# Analyze update logs
grep -E "(ERROR|WARN|FAIL)" ~/.dotfiles-update.log | tail -10

# Check for patterns
grep -c "SUCCESS" ~/.dotfiles-update.log
grep -c "ERROR" ~/.dotfiles-update.log

# View logs by date
grep "$(date +%Y-%m-%d)" ~/.dotfiles-update.log
```

### Network Diagnostics

```bash
# Test connectivity to key services
curl -Is https://github.com | head -1
curl -Is https://api.github.com | head -1
curl -Is https://registry.npmjs.org | head -1

# DNS resolution
nslookup github.com
nslookup registry.npmjs.org
```

## 🔄 Recovery Procedures

### Complete System Reset

If everything is broken, nuclear option:

```bash
# 1. Backup current state
cp -r ~/.dotfiles ~/.dotfiles.broken
cp ~/.bashrc ~/.bashrc.broken
cp -r ~/.config/fish ~/.config/fish.broken

# 2. Clean slate
rm -rf ~/.dotfiles
rm ~/.bashrc ~/.gitconfig
rm -rf ~/.config/fish

# 3. Fresh installation
git clone https://github.com/arjaygg/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./scripts/install-traditional.sh
dotfiles schedule daily
```

### Restore from Backup

```bash
# List available backups
ls -la ~/.dotfiles-backups/

# Restore specific configuration
BACKUP_DATE="20240630_120000"  # Choose your backup
cp ~/.dotfiles-backups/$BACKUP_DATE/.bashrc ~/
cp -r ~/.dotfiles-backups/$BACKUP_DATE/.config/fish ~/.config/

# Restart shell
exec $SHELL
```

### Selective Reset

```bash
# Reset just symlinks
dotfiles sync --force

# Reset just automation
crontab -l | grep -v dotfiles | crontab -
dotfiles schedule daily

# Reset just tools
dotfiles install
```

## 📞 Getting Help

### Information to Gather

When seeking help, collect this information:

```bash
# System information
uname -a
echo $SHELL
echo $PATH

# Dotfiles status
dotfiles status
dotfiles doctor

# Recent logs
tail -20 ~/.dotfiles-update.log

# Git status
cd ~/.dotfiles && git status
cd ~/.dotfiles && git log --oneline -5
```

### Common Support Resources

1. **Check Documentation**: [AUTOMATION.md](AUTOMATION.md), [ARCHITECTURE.md](ARCHITECTURE.md)
2. **Run Diagnostics**: `dotfiles doctor`
3. **Check Issues**: Search repository issues on GitHub
4. **Community Help**: Development community forums

Remember: The system is designed to be self-healing. Most issues can be resolved with `dotfiles doctor` and `dotfiles sync --force`.