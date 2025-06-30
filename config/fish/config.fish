# Fish shell configuration for dotfiles
# This config prioritizes Fish features while maintaining compatibility

# Source shared shell configurations
if test -f "$HOME/.dotfiles/config/shell/exports.fish"
    source "$HOME/.dotfiles/config/shell/exports.fish"
end

if test -f "$HOME/.dotfiles/config/shell/aliases.fish"
    source "$HOME/.dotfiles/config/shell/aliases.fish"
end

# Fish-specific settings
set -g fish_greeting ""  # Disable greeting message

# Set default editor
set -gx EDITOR nvim
set -gx VISUAL $EDITOR

# History settings
set -g fish_history_max 10000

# Colors and theme
set -g fish_color_command blue
set -g fish_color_param normal
set -g fish_color_comment brblack
set -g fish_color_error red
set -g fish_color_operator cyan
set -g fish_color_quote yellow
set -g fish_color_redirection magenta

# Path modifications
fish_add_path -g "$HOME/.local/bin"
fish_add_path -g "$HOME/bin"

# Language and locale
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

# Development environments
if test -d "$HOME/go"
    set -gx GOPATH "$HOME/go"
    set -gx GOBIN "$GOPATH/bin"
    fish_add_path -g "$GOBIN"
end

if test -d "$HOME/.cargo"
    set -gx CARGO_HOME "$HOME/.cargo"
    fish_add_path -g "$CARGO_HOME/bin"
end

if test -d "$HOME/.npm-global"
    set -gx NPM_CONFIG_PREFIX "$HOME/.npm-global"
    fish_add_path -g "$NPM_CONFIG_PREFIX/bin"
end

# Platform-specific configurations
switch (uname)
case Darwin
    # macOS specific
    set -gx HOMEBREW_NO_ANALYTICS 1
    set -gx HOMEBREW_NO_INSECURE_REDIRECT 1
    
    # Add Homebrew to path
    if test -d "/opt/homebrew"
        fish_add_path -g "/opt/homebrew/bin"
        fish_add_path -g "/opt/homebrew/sbin"
    else if test -d "/usr/local/Homebrew"
        fish_add_path -g "/usr/local/bin"
        fish_add_path -g "/usr/local/sbin"
    end
case Linux
    # Linux specific
    set -gx XDG_CONFIG_HOME "$HOME/.config"
    set -gx XDG_DATA_HOME "$HOME/.local/share"
    set -gx XDG_CACHE_HOME "$HOME/.cache"
end

# Nix integration
if command -v nix >/dev/null 2>&1
    if test -d "$HOME/.nix-profile"
        fish_add_path -g "$HOME/.nix-profile/bin"
    end
    
    if test -d "/nix/var/nix/profiles/default"
        fish_add_path -g "/nix/var/nix/profiles/default/bin"
    end
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

# Git configuration
set -gx GIT_EDITOR "$EDITOR"

# GPG configuration
set -gx GPG_TTY (tty)

# Initialize starship prompt if available
if command -v starship >/dev/null 2>&1
    starship init fish | source
end

# Initialize zoxide if available
if command -v zoxide >/dev/null 2>&1
    zoxide init fish | source
end

# Initialize direnv if available
if command -v direnv >/dev/null 2>&1
    direnv hook fish | source
end