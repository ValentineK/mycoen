#!/bin/bash

# Terminal Environment Setup Script
# This script sets up a comfortable terminal environment with zsh, oh-my-zsh, and essential plugins

# Exit on error
set -e

# Color formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    log_error "Please don't run as root"
    exit 1
fi

# Detect package manager
if command -v apt-get >/dev/null 2>&1; then
    PKG_MANAGER="apt-get"
    PKG_UPDATE="sudo apt-get update"
    PKG_INSTALL="sudo apt-get install -y"
elif command -v yum >/dev/null 2>&1; then
    PKG_MANAGER="yum"
    PKG_UPDATE="sudo yum update"
    PKG_INSTALL="sudo yum install -y"
else
    log_error "Unsupported package manager. This script requires apt or yum."
    exit 1
fi

# Update package manager
log_info "Updating package manager..."
eval $PKG_UPDATE

# Install required packages
log_info "Installing required packages..."
PACKAGES=(
    git
    curl
    zsh
    util-linux
    python3
    python3-pip
)

eval $PKG_INSTALL "${PACKAGES[@]}"

# Install Oh My Zsh
log_info "Installing Oh My Zsh..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    log_warn "Oh My Zsh is already installed. Skipping..."
else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Create zshrc configuration
log_info "Creating zsh configuration..."
cat > "$HOME/.zshrc" << 'EOL'
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
export LANG="en_US.UTF-8"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

# Custom aliases
alias ll='ls -la'
alias h='history'
alias c='clear'

# Functions
glop() {
    git log --oneline --no-decorate --oneline origin/master..HEAD | \
        awk '{print "* ["substr($0, 9, 1000)"]""("substr($0, 0, 7)")" }'
}
EOL

# Install zsh-autosuggestions
log_info "Installing zsh-autosuggestions..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Install zsh-syntax-highlighting
log_info "Installing zsh-syntax-highlighting..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Install fzf
log_info "Installing fzf..."
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all

# Set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    log_info "Setting zsh as default shell..."
    chsh -s $(which zsh)
fi

# Final setup
log_info "Setup complete! Please log out and log back in to use your new shell environment."
log_info "You may want to install a Powerline-compatible font for the agnoster theme to display correctly."

EOL

This script:

1. Installs essential packages:
   - git, curl, zsh
   - util-linux
   - Python 3

2. Sets up Oh My Zsh with:
   - Agnoster theme
   - Useful plugins including git, docker, kubectl
   - Syntax highlighting
   - Auto-suggestions

3. Configures:
   - Custom aliases
   - PATH settings
   - UTF-8 language settings
   - The glop function for git log formatting

To use this script:

```bash
# Download the script
curl -O https://raw.githubusercontent.com/yourusername/dotfiles/main/setup.sh

# Make it executable
chmod +x setup.sh

# Run it
./setup.sh
```

You'll need to:
1. Host this script somewhere accessible (like GitHub)
2. Log out and log back in after running it
3. Install a Powerline-compatible font for the agnoster theme to display correctly

Would you like me to modify anything in the script or add additional features?