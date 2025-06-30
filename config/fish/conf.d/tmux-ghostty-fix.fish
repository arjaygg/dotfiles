# Fix for Ghostty terminal compatibility with tmux.fish plugin
# Addresses issue where tput colors fails with "xterm-ghostty" terminal type

# Override tput to handle Ghostty terminal gracefully
function tput --wraps tput
    # If tput fails (like with xterm-ghostty), provide safe defaults
    if not command tput $argv 2>/dev/null
        switch $argv[1]
            case colors
                # Default to 256 colors for modern terminals
                echo "256"
            case '*'
                # For other tput commands, return empty/safe defaults
                return 1
        end
    else
        command tput $argv
    end
end