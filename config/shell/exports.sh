# Shared environment variables for both Nix and traditional setups
# This file should be sourced by both Nix modules and traditional shell configs

# Editor preferences
export EDITOR="nvim"
export VISUAL="$EDITOR"
export PAGER="less"

# Less configuration
export LESS="-R -F -X -i -M -w -z-4"
export LESSOPEN="|bat %s 2>/dev/null || cat %s"

# History configuration
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help"

# Colors
export CLICOLOR=1
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd

# Language and locale - use en_US.UTF-8 (standard locale)
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
unset LANGUAGE

# Development paths and configurations
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export CARGO_HOME="$HOME/.cargo"
export RUSTUP_HOME="$HOME/.rustup"

# Node.js
export NODE_ENV=development
# NPM_CONFIG_PREFIX conflicts with nvm - commented out for nvm compatibility
# export NPM_CONFIG_PREFIX="$HOME/.npm-global"

# Python
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1

# Path modifications (only if directories exist)
add_to_path() {
    if [[ -d "$1" && ":$PATH:" != *":$1:"* ]]; then
        export PATH="$1:$PATH"
    fi
}

# Add common development paths
add_to_path "$HOME/.local/bin"
add_to_path "$HOME/bin"
add_to_path "$GOBIN"
add_to_path "$CARGO_HOME/bin"
# add_to_path "$NPM_CONFIG_PREFIX/bin"  # Disabled for nvm compatibility
add_to_path "$HOME/.yarn/bin"

# Platform-specific exports
case "$(uname -s)" in
    Darwin*)
        # macOS specific
        export HOMEBREW_NO_ANALYTICS=1
        export HOMEBREW_NO_INSECURE_REDIRECT=1
        export HOMEBREW_CASK_OPTS="--require-sha"
        
        # Add Homebrew paths if they exist
        if [[ -d "/opt/homebrew" ]]; then
            add_to_path "/opt/homebrew/bin"
            add_to_path "/opt/homebrew/sbin"
        elif [[ -d "/usr/local/Homebrew" ]]; then
            add_to_path "/usr/local/bin"
            add_to_path "/usr/local/sbin"
        fi
        ;;
    Linux*)
        # Linux specific
        export XDG_CONFIG_HOME="$HOME/.config"
        export XDG_DATA_HOME="$HOME/.local/share"
        export XDG_CACHE_HOME="$HOME/.cache"
        ;;
esac

# Nix-specific exports (if Nix is available)
if command -v nix >/dev/null 2>&1; then
    export NIX_PATH="$HOME/.nix-defexpr/channels:$NIX_PATH"
    
    # Add Nix paths
    if [[ -d "$HOME/.nix-profile" ]]; then
        add_to_path "$HOME/.nix-profile/bin"
    fi
    
    # Multi-user Nix installation
    if [[ -d "/nix/var/nix/profiles/default" ]]; then
        add_to_path "/nix/var/nix/profiles/default/bin"
    fi
fi

# Tool-specific configurations
if command -v bat >/dev/null 2>&1; then
    export BAT_THEME="gruvbox-dark"
    export BAT_STYLE="numbers,changes,header"
fi

if command -v fzf >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
fi

if command -v rg >/dev/null 2>&1; then
    export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"
fi

# Git configuration
export GIT_EDITOR="$EDITOR"

# SSH configuration
export SSH_KEY_PATH="$HOME/.ssh/id_rsa"

# GPG configuration
export GPG_TTY=$(tty)

# Cleanup function
unset -f add_to_path