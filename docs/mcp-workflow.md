# MCP Tools Workflow Guide

## Overview

This guide covers the day-to-day workflow for managing MCP (Model Context Protocol) tools in your dotfiles setup.

## Installation Workflow

### New Machine Setup
```bash
# 1. Clone dotfiles
git clone <your-dotfiles-repo> ~/git/dotfiles

# 2. Install everything (includes MCP tools)
cd ~/git/dotfiles
dotfiles install

# 3. Verify MCP setup
dotfiles mcp status
```

## Daily Usage

### Check Status
```bash
# Overall system status (includes MCP)
dotfiles status

# Detailed MCP status
dotfiles mcp status
```

### Update Everything
```bash
# Update all tools including MCP packages
dotfiles update

# This automatically:
# - Updates npm packages (including MCP tools)
# - Regenerates Claude CLI config
# - Syncs all configurations
```

### Sync Configurations
```bash
# Sync dotfiles configurations
dotfiles sync

# This ensures all symlinks are correct
```

## Adding New MCP Tools

### Step-by-Step Process

1. **Edit MCP configuration:**
   ```bash
   vim ~/git/dotfiles/config/mcp/servers.json
   ```

2. **Add the new tool definition:**
   ```json
   {
     "mcpServers": {
       "existing-tools": "...",
       "new-tool": {
         "command": "npx",
         "args": ["@anthropic/mcp-new-tool"],
         "description": "What this tool does"
       }
     }
   }
   ```

3. **Regenerate Claude CLI configuration:**
   ```bash
   dotfiles mcp regenerate
   ```

4. **Install the npm package:**
   ```bash
   npm install -g @anthropic/mcp-new-tool
   ```

5. **Verify everything works:**
   ```bash
   dotfiles mcp status
   ```

### Example: Adding File System MCP Tool

```bash
# 1. Edit config
vim ~/git/dotfiles/config/mcp/servers.json

# Add this to mcpServers:
# "filesystem": {
#   "command": "npx", 
#   "args": ["@anthropic/mcp-filesystem"],
#   "description": "File system operations with controlled access"
# }

# 2. Regenerate config
dotfiles mcp regenerate

# 3. Install package
npm install -g @anthropic/mcp-filesystem

# 4. Verify
dotfiles mcp status
```

## Troubleshooting

### Common Issues

#### MCP Tools Not Working
```bash
# Check status
dotfiles mcp status

# Regenerate configurations
dotfiles mcp regenerate

# Check if packages are installed
npm list -g | grep mcp
```

#### Claude CLI Can't Find MCP Tools
```bash
# Check Claude config
ls -la ~/.config/claude/settings.json

# Verify it points to the right place
cat ~/.config/claude/settings.json | head -10

# Regenerate if needed
dotfiles mcp regenerate
```

#### Node.js Issues
```bash
# Check Node.js installation
node --version
npm --version

# If missing, install via dotfiles
dotfiles install

# Or install manually
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### Reset Everything
```bash
# Nuclear option - reinstall everything
rm -rf ~/.config/claude ~/.config/mcp
dotfiles install
```

## Automation Features

### Pre-commit Hook
- Automatically regenerates Claude CLI config when you commit changes to MCP servers
- Ensures configurations stay synchronized
- No manual intervention required

### Update Integration
- `dotfiles update` automatically handles MCP tool updates
- Regenerates configurations after package updates
- Maintains consistency across all tools

### Smart Fallbacks
- Works even without Node.js (basic configuration)
- Graceful degradation if generation fails
- Always provides working configuration

## File Structure Reference

```
~/git/dotfiles/
├── config/
│   ├── mcp/
│   │   └── servers.json              # ← Edit this to add MCP tools
│   └── claude/
│       ├── settings.json             # ← Generated automatically
│       └── settings.template.json    # Template for Claude settings
├── scripts/
│   ├── generate-claude-config.js     # Generator script
│   ├── setup-claude-mcp.sh          # Setup script
│   └── git-hooks/
│       └── pre-commit                # Auto-regeneration hook
└── docs/
    ├── claude-mcp-setup.md           # Full setup guide
    └── mcp-workflow.md               # This file

~/.config/
├── mcp/
│   └── servers.json → ~/git/dotfiles/config/mcp/servers.json
└── claude/
    └── settings.json → ~/git/dotfiles/config/claude/settings.json
```

## Commands Quick Reference

| Command | Purpose |
|---------|---------|
| `dotfiles install` | Fresh installation (includes MCP) |
| `dotfiles update` | Update everything (includes MCP) |
| `dotfiles sync` | Sync configurations |
| `dotfiles status` | Show overall status |
| `dotfiles mcp status` | Detailed MCP status |
| `dotfiles mcp regenerate` | Regenerate Claude config |
| `dotfiles mcp setup` | Full MCP setup (rarely needed) |

## Best Practices

1. **Always test after changes:**
   ```bash
   dotfiles mcp status
   ```

2. **Use descriptive tool descriptions:**
   ```json
   "description": "Clear description of what this tool does"
   ```

3. **Commit MCP changes properly:**
   ```bash
   git add config/mcp/servers.json
   git commit -m "add: new MCP tool for X functionality"
   # Pre-commit hook will auto-add the generated Claude config
   ```

4. **Keep tools updated:**
   ```bash
   dotfiles update  # Run regularly
   ```

5. **Use consistent naming:**
   - Tool names should match the npm package suffix
   - Example: `@anthropic/mcp-filesystem` → tool name: `filesystem`