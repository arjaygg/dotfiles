# Fish-compatible aliases for dotfiles
# Converted from aliases.sh for Fish shell syntax

# Navigation
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ~ 'cd ~'

# List files
if command -v eza >/dev/null 2>&1
    alias ls 'eza'
    alias ll 'eza -la'
    alias la 'eza -la'
    alias lt 'eza --tree'
else if command -v lsd >/dev/null 2>&1
    alias ls 'lsd'
    alias ll 'lsd -la'
    alias la 'lsd -la'
    alias lt 'lsd --tree'
else
    alias ll 'ls -la'
    alias la 'ls -la'
end

# Better cat
if command -v bat >/dev/null 2>&1
    alias cat 'bat'
    alias ccat 'command cat'  # Original cat
end

# Better grep
if command -v rg >/dev/null 2>&1
    alias grep 'rg'
    alias ggrep 'command grep'  # Original grep
end

# Better find
if command -v fd >/dev/null 2>&1
    alias find 'fd'
    alias ffind 'command find'  # Original find
end

# Git aliases
alias g 'git'
alias ga 'git add'
alias gaa 'git add .'
alias gc 'git commit'
alias gcm 'git commit -m'
alias gco 'git checkout'
alias gcb 'git checkout -b'
alias gd 'git diff'
alias gl 'git log --oneline'
alias gp 'git push'
alias gpl 'git pull'
alias gs 'git status'
alias gst 'git stash'
alias gsp 'git stash pop'

# Directory shortcuts
alias dl 'cd ~/Downloads'
alias dt 'cd ~/Desktop'
alias docs 'cd ~/Documents'
alias dev 'cd ~/Development'
alias dots 'cd ~/.dotfiles'

# System utilities
alias df 'df -h'
alias du 'du -h'
alias free 'free -h'
alias ports 'netstat -tuln'
alias myip 'curl -s ifconfig.me'

# Quick edits
alias vimrc '$EDITOR ~/.vimrc'
alias nvimrc '$EDITOR ~/.config/nvim/init.lua'
alias fishrc '$EDITOR ~/.config/fish/config.fish'

# Tmux
alias tm 'tmux'
alias tma 'tmux attach'
alias tmn 'tmux new'
alias tml 'tmux list-sessions'

# Quick commands
alias reload 'source ~/.config/fish/config.fish'
alias path 'echo $PATH | tr ":" "\n"'
alias h 'history'
alias j 'jobs'
alias c 'clear'
alias x 'exit'

# Platform-specific aliases
switch (uname)
case Darwin
    # macOS specific
    alias pbcopy 'pbcopy'
    alias pbpaste 'pbpaste'
    alias open 'open'
    alias flush-dns 'sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
case Linux
    # Linux specific
    if command -v xclip >/dev/null 2>&1
        alias pbcopy 'xclip -selection clipboard'
        alias pbpaste 'xclip -selection clipboard -o'
    else if command -v xsel >/dev/null 2>&1
        alias pbcopy 'xsel --clipboard --input'
        alias pbpaste 'xsel --clipboard --output'
    end
    alias open 'xdg-open'
    alias flush-dns 'sudo systemctl restart systemd-resolved'
end

# Development aliases
alias py 'python3'
alias pip 'pip3'
alias serve 'python3 -m http.server'
alias json 'python3 -m json.tool'

# Docker aliases (if available)
if command -v docker >/dev/null 2>&1
    alias d 'docker'
    alias dc 'docker-compose'
    alias dps 'docker ps'
    alias di 'docker images'
    alias dex 'docker exec -it'
end

# Kubernetes aliases (if available)
if command -v kubectl >/dev/null 2>&1
    alias k 'kubectl'
    alias kgp 'kubectl get pods'
    alias kgs 'kubectl get services'
    alias kgn 'kubectl get nodes'
    alias kdp 'kubectl describe pod'
    alias kl 'kubectl logs'
end

# Nix-specific aliases (if available)
if command -v nix >/dev/null 2>&1
    alias nix-shell 'nix-shell'
    alias nix-env 'nix-env'
    alias nix-build 'nix-build'
    alias nix-collect-garbage 'nix-collect-garbage -d'
    alias nixos-rebuild 'sudo nixos-rebuild'
end

# Home Manager aliases (if available)
if command -v home-manager >/dev/null 2>&1
    alias hm 'home-manager'
    alias hms 'home-manager switch'
    alias hmb 'home-manager build'
end