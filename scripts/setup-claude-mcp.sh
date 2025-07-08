#!/bin/bash

# Setup Claude MCP configuration across machines
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"
CLAUDE_CONFIG_DIR="$HOME/.config/claude"
MCP_CONFIG_DIR="$HOME/.config/mcp"
DOTFILES_CLAUDE_CONFIG="$DOTFILES_ROOT/config/claude"
DOTFILES_MCP_CONFIG="$DOTFILES_ROOT/config/mcp"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if npm is available
if ! command -v npm >/dev/null 2>&1; then
    log_error "npm not found. MCP tools require npm. Install Node.js first."
    exit 1
fi

# Check if Claude CLI is installed (optional)
if ! command -v claude >/dev/null 2>&1; then
    log_warn "Claude CLI not found - MCP tools will be installed but won't be usable until you install an MCP-compatible AI client"
    log_info "MCP tools work with Claude CLI, Cline, and other MCP-compatible AI assistants"
else
    log_info "Claude CLI found - MCP tools will be fully functional"
fi

# Create config directories
mkdir -p "$CLAUDE_CONFIG_DIR" "$MCP_CONFIG_DIR"

# Setup generic MCP configuration 
if [ -f "$DOTFILES_MCP_CONFIG/servers.json" ]; then
    log_info "Linking generic MCP servers configuration..."
    ln -sf "$DOTFILES_MCP_CONFIG/servers.json" "$MCP_CONFIG_DIR/servers.json"
    log_info "✓ Generic MCP configuration linked"
fi

# Generate Claude CLI configuration from generic MCP config
if [ -f "$DOTFILES_MCP_CONFIG/servers.json" ]; then
    log_info "Generating Claude CLI config from generic MCP servers..."
    if command -v node >/dev/null 2>&1; then
        if "$SCRIPT_DIR/generate-claude-config.js"; then
            log_info "✓ Claude CLI config generated from generic MCP config"
        else
            log_warn "Failed to generate Claude CLI config, using fallback"
        fi
    else
        log_warn "Node.js not found, using manual config generation"
    fi
fi

# Setup Claude CLI configuration (generated or existing)
if [ -f "$DOTFILES_CLAUDE_CONFIG/settings.json" ]; then
    log_info "Linking generated Claude CLI settings..."
    ln -sf "$DOTFILES_CLAUDE_CONFIG/settings.json" "$CLAUDE_CONFIG_DIR/settings.json"
    log_info "✓ Claude CLI settings linked (MCP + permissions, no duplication)"
else
    log_warn "No Claude CLI config found. Creating fallback configuration..."
    cat > "$CLAUDE_CONFIG_DIR/settings.json" << 'EOF'
{
  "mcpServers": {
    "markdownify": {
      "command": "npx",
      "args": ["@anthropic/mcp-markdownify"],
      "description": "Convert various file formats to markdown"
    }
  },
  "permissions": {
    "allow": ["*"],
    "deny": []
  },
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1"
  },
  "cleanupPeriodDays": 30,
  "includeCoAuthoredBy": true
}
EOF
    log_info "✓ Fallback Claude CLI configuration created"
fi

# Install global MCP packages from configuration
log_info "Installing global MCP packages..."
if [ -f "$DOTFILES_MCP_CONFIG/servers.json" ]; then
    # Extract package names from MCP config
    if command -v jq >/dev/null 2>&1; then
        mcp_packages=$(jq -r '.mcpServers[].args[0]' "$DOTFILES_MCP_CONFIG/servers.json" 2>/dev/null)
        if [ -n "$mcp_packages" ]; then
            echo "$mcp_packages" | while IFS= read -r package; do
                if [ -n "$package" ] && echo "$package" | grep -q "^@anthropic/mcp-"; then
                    log_info "Installing MCP package: $package"
                    npm install -g "$package" 2>/dev/null || log_warn "Failed to install $package"
                fi
            done
        else
            log_warn "No MCP packages found in configuration"
        fi
    else
        log_warn "jq not available, installing default MCP packages..."
        # Fallback to hardcoded list
        npm install -g @anthropic/mcp-markdownify 2>/dev/null || log_warn "Failed to install mcp-markdownify"
        npm install -g @anthropic/mcp-context7 2>/dev/null || log_warn "Failed to install mcp-context7"
        npm install -g @anthropic/mcp-office-powerpoint 2>/dev/null || log_warn "Failed to install mcp-office-powerpoint"
        npm install -g @anthropic/mcp-directory-tree 2>/dev/null || log_warn "Failed to install mcp-directory-tree"
        npm install -g @anthropic/mcp-video 2>/dev/null || log_warn "Failed to install mcp-video"
    fi
else
    log_warn "MCP configuration not found, skipping package installation"
fi

log_info "✓ MCP tools setup complete!"
log_info "You can now use MCP tools with any MCP-compatible AI assistant."

# Verify installation
log_info "Verifying installation..."
if [ -f "$HOME/.config/claude/settings.json" ]; then
    log_info "✓ MCP configuration exists at ~/.config/claude/settings.json"
else
    log_error "❌ MCP configuration missing"
fi

# Check for at least one MCP package
if npm list -g @anthropic/mcp-markdownify >/dev/null 2>&1; then
    log_info "✓ MCP packages installed globally"
else
    log_warn "⚠ MCP packages may not be installed correctly"
fi

# Show usage information
echo
log_info "📚 MCP Tools Available:"
echo "  • markdownify     - Convert files to markdown"
echo "  • context7        - Library documentation access"  
echo "  • office-powerpoint - Create/edit PowerPoint presentations"
echo "  • directory-tree  - Generate directory structures"
echo "  • video          - Video processing and transcription"
echo
log_info "🔧 Compatible AI Clients:"
echo "  • Claude Code CLI - Official Anthropic client"
echo "  • Cline (VS Code) - Popular VS Code extension"
echo "  • Continue.dev    - Open-source coding assistant"
echo "  • Other MCP-compatible tools"
echo
log_info "📖 Configuration files:"
echo "  • ~/.config/claude/settings.json - Claude Code CLI"
echo "  • ~/.config/mcp/servers.json     - Generic MCP config"
echo
log_info "Other MCP clients can reference either configuration file."
log_info "Check client documentation for configuration file location and format."