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

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

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

# Fisher plugins installed:
# - IlanCosman/tide@v6      # Modern, fast prompt
# - PatrickF1/fzf.fish      # Fuzzy finder integration
# - jethrokuan/z            # Directory jumping