# Minimal Fish shell configuration
# Start simple and build up gradually

# Disable greeting message
set -g fish_greeting ""

# Basic environment variables
set -gx EDITOR nvim
set -gx VISUAL $EDITOR

# Essential PATH additions
fish_add_path -g "$HOME/.local/bin"
fish_add_path -g "$HOME/bin"

# Basic colors
set -g fish_color_command blue
set -g fish_color_param normal
set -g fish_color_comment brblack
set -g fish_color_error red

# Essential development paths
if test -d "$HOME/.cargo"
    fish_add_path -g "$HOME/.cargo/bin"
end

if test -d "$HOME/.npm-global"
    fish_add_path -g "$HOME/.npm-global/bin"
end

if test -d "$HOME/go"
    set -gx GOPATH "$HOME/go"
    fish_add_path -g "$HOME/go/bin"
end

# Platform-specific essentials
switch (uname)
case Linux
    set -gx XDG_CONFIG_HOME "$HOME/.config"
    set -gx XDG_DATA_HOME "$HOME/.local/share"
    set -gx XDG_CACHE_HOME "$HOME/.cache"
case Darwin
    set -gx HOMEBREW_NO_ANALYTICS 1
    if test -d "/opt/homebrew"
        fish_add_path -g "/opt/homebrew/bin"
    end
end

# Essential aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias home='cd ~'
alias myip='curl -s ifconfig.me'

# Git abbreviations are automatically loaded by jhillyerd/plugin-git
# Use fish-abbreviation-tips to see suggestions as you type
# Commands: abbr --show, alias, functions

# Source shared shell configurations (if they exist)
if test -f "$HOME/git/dotfiles/config/shell/exports.fish"
    source "$HOME/git/dotfiles/config/shell/exports.fish"
end

if test -f "$HOME/git/dotfiles/config/shell/aliases.fish"
    source "$HOME/git/dotfiles/config/shell/aliases.fish"
end

# Tool integrations
if command -v zoxide >/dev/null 2>&1
    zoxide init fish | source
end

if command -v direnv >/dev/null 2>&1
    direnv hook fish | source
end

if command -v atuin >/dev/null 2>&1
    atuin init fish | source
end

# FZF configuration
if command -v fzf >/dev/null 2>&1
    # Set FZF environment variables
    set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border'
end

# Fisher plugins installed:
# - IlanCosman/tide@v6                    # Modern, fast prompt
# - jhillyerd/plugin-git                  # Git abbreviations (168 total)
# - gazorby/fish-abbreviation-tips        # Shows abbreviation suggestions
# - PatrickF1/fzf.fish                    # Fuzzy finder integration
# - jethrokuan/z                          # Directory jumping
# - budimanjojo/tmux.fish                 # Tmux integration  
# - barnybug/docker-fish-completion       # Docker completions
# - derphilipp/enter-docker-fzf           # Docker container selector
# - dteoh/fish-homebrew-asdf              # Homebrew + asdf integration
# - jorgebucaran/nvm.fish                 # Node version manager

# Additional tools integrated:
# - atuin                   # Enhanced shell history with sync
# - zoxide                  # Smarter cd command
# - direnv                  # Directory-specific environment variables
# OpenCode integration (if available)
if test -d "$HOME/.opencode"
    fish_add_path -g "$HOME/.opencode/bin"
end

# Initialize Homebrew environment if available
if command -v brew >/dev/null 2>&1
    eval (brew shellenv)
end
