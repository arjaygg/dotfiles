# Shared shell aliases for both Nix and traditional setups
# This file should be sourced by both Nix modules and traditional shell configs

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# List files
if command -v eza >/dev/null 2>&1; then
    alias ls='eza'
    alias ll='eza -la'
    alias la='eza -la'
    alias lt='eza --tree'
elif command -v lsd >/dev/null 2>&1; then
    alias ls='lsd'
    alias ll='lsd -la'
    alias la='lsd -la'
    alias lt='lsd --tree'
else
    alias ll='ls -la'
    alias la='ls -la'
fi

# Better cat
if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
    alias ccat='cat' # Original cat
fi

# Better grep
if command -v rg >/dev/null 2>&1; then
    alias grep='rg'
    alias ggrep='grep' # Original grep
fi

# Better find
if command -v fd >/dev/null 2>&1; then
    alias find='fd'
    alias ffind='find' # Original find
fi

# Git aliases - Note: Fish shell uses jhillyerd/plugin-git Fisher plugin for enhanced git aliases

# Directory shortcuts
alias dl='cd ~/Downloads'
alias dt='cd ~/Desktop'
alias docs='cd ~/Documents'
alias dev='cd ~/Development'
alias dots='cd ~/.dotfiles'

# System utilities
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ports='netstat -tuln'
alias myip='curl -s ifconfig.me'

# Quick edits
alias vimrc='$EDITOR ~/.vimrc'
alias nvimrc='$EDITOR ~/.config/nvim/init.lua'
alias zshrc='$EDITOR ~/.zshrc'
alias bashrc='$EDITOR ~/.bashrc'
alias fishrc='$EDITOR ~/.config/fish/config.fish'

# Tmux
alias tm='tmux'
alias tma='tmux attach'
alias tmn='tmux new'
alias tml='tmux list-sessions'

# Quick commands
alias reload='source ~/.bashrc || source ~/.zshrc || source ~/.config/fish/config.fish'
alias path='echo $PATH | tr ":" "\n"'
alias h='history'
alias j='jobs'
alias c='clear'
alias x='exit'

# Platform-specific aliases
case "$(uname -s)" in
    Darwin*)
        # macOS specific
        alias pbcopy='pbcopy'
        alias pbpaste='pbpaste'
        alias open='open'
        alias flush-dns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
        ;;
    Linux*)
        # Linux specific
        if command -v xclip >/dev/null 2>&1; then
            alias pbcopy='xclip -selection clipboard'
            alias pbpaste='xclip -selection clipboard -o'
        elif command -v xsel >/dev/null 2>&1; then
            alias pbcopy='xsel --clipboard --input'
            alias pbpaste='xsel --clipboard --output'
        fi
        alias open='xdg-open'
        alias flush-dns='sudo systemctl restart systemd-resolved'
        ;;
esac

# Development aliases
alias py='python3'
alias pip='pip3'
alias serve='python3 -m http.server'
alias json='python3 -m json.tool'

# Docker aliases (if available)
if command -v docker >/dev/null 2>&1; then
    alias d='docker'
    alias dc='docker-compose'
    alias dps='docker ps'
    alias di='docker images'
    alias dex='docker exec -it'
fi

# Kubernetes aliases (if available)
if command -v kubectl >/dev/null 2>&1; then
    alias k='kubectl'
    alias kgp='kubectl get pods'
    alias kgs='kubectl get services'
    alias kgn='kubectl get nodes'
    alias kdp='kubectl describe pod'
    alias kl='kubectl logs'
fi

# Nix-specific aliases (if available)
if command -v nix >/dev/null 2>&1; then
    alias nix-shell='nix-shell'
    alias nix-env='nix-env'
    alias nix-build='nix-build'
    alias nix-collect-garbage='nix-collect-garbage -d'
    alias nixos-rebuild='sudo nixos-rebuild'
fi

# Home Manager aliases (if available)
if command -v home-manager >/dev/null 2>&1; then
    alias hm='home-manager'
    alias hms='home-manager switch'
    alias hmb='home-manager build'
fi