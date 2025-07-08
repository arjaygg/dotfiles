# MCP Setup Guide

This guide explains how to set up MCP (Model Context Protocol) tools across different machines and projects. MCP tools work with Claude Code, Cline, Continue.dev, and other MCP-compatible AI assistants.

## Quick Setup

### First-Time Installation
```bash
# Fresh installation (includes MCP tools automatically)
dotfiles install

# This automatically:
# - Installs all MCP packages defined in config/mcp/servers.json
# - Sets up configurations for Claude CLI and generic MCP clients
# - Links all configurations to your dotfiles

# Verify installation
dotfiles status
dotfiles mcp status
```

### Daily Usage
```bash
# Update everything (including MCP tools)
dotfiles update

# Sync configurations
dotfiles sync

# Check MCP status
dotfiles mcp status

# Regenerate Claude config after editing MCP servers
dotfiles mcp regenerate
```

## Global vs Project-Specific Configuration

### Generic MCP Configuration
- **Primary location**: `~/.config/mcp/servers.json`
- **Contains**: Universal MCP server definitions
- **Used by**: Any MCP-compatible client that supports this format

### Claude CLI Configuration
- **Location**: `~/.config/claude/settings.json`
- **Links to**: Claude-specific dotfiles config (symlinked)  
- **Contains**: MCP servers + Claude settings (permissions, env, etc.)
- **Used by**: Claude Code CLI specifically
- **Note**: This is a complete Claude CLI config file, not just MCP servers

### Project-Specific Configuration  
- **Location**: `<project-root>/.claude/settings.json` 
- **Contains**: Project-specific tools (filesystem, sqlite, github, etc.)
- **Override**: Global settings for specific projects

## Configuration Architecture

The setup uses **smart generation** to avoid duplication:

```
dotfiles/
├── config/
│   ├── mcp/
│   │   └── servers.json              # Source: Generic MCP servers
│   └── claude/
│       ├── settings.json             # Generated: MCP + Claude settings
│       └── settings.template.json    # Template: Claude-only settings
├── scripts/
│   └── generate-claude-config.js     # Generator script
│
~/.config/
├── mcp/
│   └── servers.json → dotfiles/config/mcp/servers.json
└── claude/
    └── settings.json → dotfiles/config/claude/settings.json
```

**How it works:**
1. **Source of truth**: `config/mcp/servers.json` contains MCP server definitions
2. **Generation**: Script combines MCP servers + Claude template → full Claude config
3. **Automatic updates**: Pre-commit hook regenerates Claude config when MCP config changes
4. **No duplication**: MCP servers defined once, Claude config generated automatically

**Benefits:**
- ✅ Single source of truth for MCP servers
- ✅ Claude gets full config (MCP + permissions + settings) 
- ✅ Other clients get clean MCP-only config
- ✅ Automatic regeneration on changes
- ✅ No manual synchronization needed

## Available MCP Tools

### Global Tools (Always Available)
- **markdownify**: Convert files to markdown
- **context7**: Library documentation access
- **office-powerpoint**: Create/edit PowerPoint presentations
- **directory-tree**: Generate directory structures
- **video**: Video processing and transcription

### Project-Specific Tools
- **filesystem**: File system access (restricted to project directory)
- **sqlite**: Database interactions
- **github**: GitHub API integration
- **time**: Date/time utilities
- **memory**: Persistent memory across sessions

## Compatible AI Clients

MCP tools work with various AI assistants:

### Claude Code CLI
- **Official Anthropic client**
- Install: `curl -fsSL https://claude.ai/cli/install.sh | sh`
- Uses: `~/.config/claude/settings.json`

### Cline (VS Code Extension)
- **Popular VS Code extension**
- Install: Search "Cline" in VS Code extensions
- Configure: Uses MCP server definitions

### Continue.dev
- **Open-source coding assistant**
- Install: Available for VS Code, JetBrains, Vim
- Configure: Add MCP servers to continue config

### Other MCP Clients
- Any tool implementing the MCP specification
- Configuration format may vary but tools remain the same

## Adding New MCP Tools

### Global Tools
1. Edit `~/git/dotfiles/config/claude/settings.json`
2. Add the new tool configuration
3. Install globally: `npm install -g @anthropic/mcp-<tool-name>`
4. Restart Claude Code

### Project-Specific Tools
1. Create `.claude/settings.json` in your project root
2. Add project-specific tool configurations
3. Install locally: `npm install @anthropic/mcp-<tool-name>`

## Troubleshooting

### Common Issues
- **Tool not found**: Check if the package is installed globally/locally
- **Permission denied**: Ensure proper file permissions on config files
- **Path issues**: Verify NODE_PATH includes global npm modules

### Debug Commands
```bash
# Check global npm packages
npm list -g --depth=0 | grep mcp

# Verify Claude configuration
claude --help

# Test MCP connection
claude --debug
```

## Managing MCP Tools

All MCP management is integrated into the main `dotfiles` command:

### Core Commands
```bash
dotfiles install        # Fresh install (includes MCP tools)
dotfiles update         # Update all tools including MCP
dotfiles sync           # Sync configurations (includes MCP config)
dotfiles status         # Show system status including MCP
```

### MCP-Specific Commands
```bash
dotfiles mcp status     # Detailed MCP tools status
dotfiles mcp regenerate # Regenerate Claude config from MCP servers
dotfiles mcp setup      # Run full MCP setup (rarely needed)
```

### Adding New MCP Tools

1. **Edit the MCP configuration:**
   ```bash
   # Edit the source configuration
   vim ~/git/dotfiles/config/mcp/servers.json
   ```

2. **Add your MCP server:**
   ```json
   {
     "mcpServers": {
       "existing-tool": { ... },
       "new-tool": {
         "command": "npx",
         "args": ["@anthropic/mcp-new-tool"],
         "description": "Description of what this tool does"
       }
     }
   }
   ```

3. **Regenerate configurations:**
   ```bash
   dotfiles mcp regenerate
   ```

4. **Install the npm package:**
   ```bash
   npm install -g @anthropic/mcp-new-tool
   ```
   
   Or, to install all packages from config:
   ```bash
   dotfiles update  # This will auto-install new packages from config
   ```

5. **Verify installation:**
   ```bash
   dotfiles mcp status
   ```

### What Gets Installed Automatically

When you run `dotfiles install` or `dotfiles update`, the system automatically:

1. **Reads your MCP configuration** (`config/mcp/servers.json`)
2. **Extracts package names** from the `args` field of each server
3. **Installs all `@anthropic/mcp-*` packages** found in the configuration
4. **Falls back to defaults** if config parsing fails

**Current packages in your configuration:**
```bash
# See what would be installed
jq -r '.mcpServers[].args[0]' ~/git/dotfiles/config/mcp/servers.json
```

This means when you add a new MCP server to your config and run `dotfiles update`, the corresponding npm package will be installed automatically!

### Automatic Synchronization

The system includes several automation features:

#### ✅ **Pre-commit Hook**
- Automatically regenerates Claude CLI config when you commit changes to `config/mcp/servers.json`
- Ensures Claude config is always in sync with MCP servers
- Adds the generated config to your commit automatically

#### ✅ **Update Integration** 
- `dotfiles update` automatically regenerates Claude config
- Keeps configurations synchronized during tool updates
- No manual intervention required

#### ✅ **Smart Fallbacks**
- If Node.js isn't available, falls back to basic configuration
- If generation fails, provides helpful error messages
- Never leaves you without a working configuration

## Cross-Machine Synchronization

When setting up on a new machine:
1. Clone dotfiles repository
2. Run `dotfiles install` (automatically includes MCP setup)
3. MCP tools and configuration will be available immediately

For existing installations:
```bash
dotfiles update         # Updates MCP tools along with other packages
dotfiles sync           # Ensures MCP configuration is properly linked
```

The global configuration will be automatically available through the dotfiles symlink and maintained during updates.

## Summary

You now have a **zero-duplication, fully automated MCP setup** integrated into your dotfiles:

### ✅ **What You Get**
- **Single command setup**: `dotfiles install` includes everything
- **Automatic updates**: `dotfiles update` keeps MCP tools current  
- **Smart configuration**: Claude CLI config generated from generic MCP config
- **Cross-platform**: Works on any machine with your dotfiles
- **Zero duplication**: MCP servers defined once, used everywhere

### 🔄 **Daily Workflow**
```bash
# Check everything
dotfiles status
dotfiles mcp status

# Update everything  
dotfiles update

# Add new MCP tool
vim ~/git/dotfiles/config/mcp/servers.json
dotfiles mcp regenerate
npm install -g @anthropic/mcp-new-tool
```

### 📚 **Learn More**
- **[MCP Workflow Guide](mcp-workflow.md)** - Day-to-day usage and troubleshooting
- **[Dotfiles Commands](../README.md)** - All available dotfiles commands
- **[Claude Code Docs](https://docs.anthropic.com/en/docs/claude-code)** - Official Claude CLI documentation

**Your MCP tools are now ready to use with Claude CLI, Cline, Continue.dev, and any future MCP-compatible AI assistants!**