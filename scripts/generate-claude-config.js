#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Paths
const DOTFILES_ROOT = path.dirname(__dirname);
const MCP_CONFIG_PATH = path.join(DOTFILES_ROOT, 'config/mcp/servers.json');
const CLAUDE_CONFIG_PATH = path.join(DOTFILES_ROOT, 'config/claude/settings.json');

// Claude-specific settings (non-MCP)
const CLAUDE_SETTINGS = {
  "permissions": {
    "allow": ["*"],
    "deny": []
  },
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1"
  },
  "cleanupPeriodDays": 30,
  "includeCoAuthoredBy": true
};

function generateClaudeConfig() {
  try {
    // Read the generic MCP config
    const mcpConfig = JSON.parse(fs.readFileSync(MCP_CONFIG_PATH, 'utf8'));
    
    // Combine MCP servers with Claude-specific settings
    const claudeConfig = {
      ...mcpConfig,  // This includes the mcpServers section
      ...CLAUDE_SETTINGS
    };
    
    // Write the combined config
    fs.writeFileSync(CLAUDE_CONFIG_PATH, JSON.stringify(claudeConfig, null, 2) + '\n');
    
    console.log('✅ Generated Claude CLI config from generic MCP config');
    console.log(`📁 Source: ${MCP_CONFIG_PATH}`);
    console.log(`📁 Target: ${CLAUDE_CONFIG_PATH}`);
    
  } catch (error) {
    console.error('❌ Failed to generate Claude config:', error.message);
    process.exit(1);
  }
}

// Run if called directly
if (require.main === module) {
  generateClaudeConfig();
}

module.exports = { generateClaudeConfig };