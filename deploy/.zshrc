# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="agnoster"

# Disable auto-update prompts
DISABLE_UPDATE_PROMPT="true"

# Plugins
plugins=(
    git
    docker
    docker-compose
    kubectl
    history
    emoji
    encode64
    z
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="/snap/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"

# Custom aliases
alias ll='ls -la'
alias h='history'
alias c='clear'

# Source all *.conf files from ~/.zshrc.d/
if [ -d "$HOME/.zshrc.d" ]; then
    for conf in "$HOME/.zshrc.d"/*.conf; do
        [ -f "$conf" ] && source "$conf"
    done
    unset conf
fi
