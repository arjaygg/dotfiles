# Fish-compatible environment variables for dotfiles
# Converted from exports.sh for Fish shell syntax

# Editor preferences
set -gx EDITOR "nvim"
set -gx VISUAL "$EDITOR"
set -gx PAGER "less"

# Less configuration
set -gx LESS "-R -F -X -i -M -w -z-4"
set -gx LESSOPEN "|bat %s 2>/dev/null || cat %s"

# History configuration (Fish handles this differently)
# Fish uses its own history system, but we can set some related vars
set -gx HISTSIZE 10000
set -gx HISTFILESIZE 20000

# Colors
set -gx CLICOLOR 1
set -gx LSCOLORS ExGxBxDxCxEgEdxbxgxcxd

# Language and locale - use C.utf8 (available locale)
set -gx LANG C.utf8
set -gx LC_ALL C.utf8
set -e LANGUAGE

# Development paths and configurations
set -gx GOPATH "$HOME/go"
set -gx GOBIN "$GOPATH/bin"
set -gx CARGO_HOME "$HOME/.cargo"
set -gx RUSTUP_HOME "$HOME/.rustup"

# Node.js
set -gx NODE_ENV development
set -gx NPM_CONFIG_PREFIX "$HOME/.npm-global"

# Python
set -gx PYTHONDONTWRITEBYTECODE 1
set -gx PYTHONUNBUFFERED 1

# Fish function to safely add to PATH
function add_to_path_if_exists
    if test -d $argv[1]
        fish_add_path -g $argv[1]
    end
end

# Add common development paths
add_to_path_if_exists "$HOME/.local/bin"
add_to_path_if_exists "$HOME/bin"
add_to_path_if_exists "$GOBIN"
add_to_path_if_exists "$CARGO_HOME/bin"
add_to_path_if_exists "$NPM_CONFIG_PREFIX/bin"
add_to_path_if_exists "$HOME/.yarn/bin"

# Platform-specific exports
switch (uname)
case Darwin
    # macOS specific
    set -gx HOMEBREW_NO_ANALYTICS 1
    set -gx HOMEBREW_NO_INSECURE_REDIRECT 1
    set -gx HOMEBREW_CASK_OPTS "--require-sha"
    
    # Add Homebrew paths if they exist
    if test -d "/opt/homebrew"
        add_to_path_if_exists "/opt/homebrew/bin"
        add_to_path_if_exists "/opt/homebrew/sbin"
    else if test -d "/usr/local/Homebrew"
        add_to_path_if_exists "/usr/local/bin"
        add_to_path_if_exists "/usr/local/sbin"
    end
case Linux
    # Linux specific
    set -gx XDG_CONFIG_HOME "$HOME/.config"
    set -gx XDG_DATA_HOME "$HOME/.local/share"
    set -gx XDG_CACHE_HOME "$HOME/.cache"
end

# Nix-specific exports (if Nix is available)
if command -v nix >/dev/null 2>&1
    set -gx NIX_PATH "$HOME/.nix-defexpr/channels:$NIX_PATH"
    
    # Add Nix paths
    add_to_path_if_exists "$HOME/.nix-profile/bin"
    
    # Multi-user Nix installation
    add_to_path_if_exists "/nix/var/nix/profiles/default/bin"
end

# Tool-specific configurations
if command -v bat >/dev/null 2>&1
    set -gx BAT_THEME "gruvbox-dark"
    set -gx BAT_STYLE "numbers,changes,header"
end

if command -v fzf >/dev/null 2>&1
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
    set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
    set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border'
end

if command -v rg >/dev/null 2>&1
    if test -f "$HOME/.config/ripgrep/config"
        set -gx RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/config"
    end
end

# Git configuration
set -gx GIT_EDITOR "$EDITOR"

# SSH configuration
set -gx SSH_KEY_PATH "$HOME/.ssh/id_rsa"

# GPG configuration
set -gx GPG_TTY (tty)

# Clean up the helper function
functions -e add_to_path_if_exists