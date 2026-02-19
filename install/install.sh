#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEPLOY_DIR="$DOTFILES_DIR/deploy"

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[•]${RESET} $*"; }
success() { echo -e "${GREEN}[✓]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[!]${RESET} $*"; }
error()   { echo -e "${RED}[✗]${RESET} $*" >&2; }
header()  { echo -e "\n${BOLD}$*${RESET}"; }

# ── Package installation helper ───────────────────────────────────────────────
install_pkg() {
    local pkg="$1"
    if command -v "$pkg" &>/dev/null; then
        success "$pkg already installed"
        return
    fi
    info "Installing $pkg..."
    if command -v apt-get &>/dev/null; then
        sudo apt-get install -y "$pkg"
    elif command -v brew &>/dev/null; then
        brew install "$pkg"
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y "$pkg"
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm "$pkg"
    else
        error "Cannot install $pkg: no supported package manager found"
        return 1
    fi
    success "$pkg installed"
}

# ── Clone or update ───────────────────────────────────────────────────────────
clone_or_update() {
    local repo="$1" dest="$2" label="$3"
    if [ -d "$dest/.git" ]; then
        local actual_remote
        actual_remote="$(git -C "$dest" remote get-url origin 2>/dev/null || echo '')"
        if [ "$actual_remote" != "$repo" ]; then
            warn "$label remote mismatch:"
            warn "  expected: $repo"
            warn "  actual:   $actual_remote"
        fi
        info "Updating $label..."
        git -C "$dest" pull --ff-only 2>&1 | tail -1
        success "$label up to date"
    else
        info "Cloning $label..."
        git clone --depth=1 "$repo" "$dest"
        success "$label cloned"
    fi
}

# ── Copy deploy files to home ─────────────────────────────────────────────────
copy_config() {
    local src="$1" dest="$2"
    local rel="${src#$DEPLOY_DIR/}"

    if [ -d "$src" ]; then
        mkdir -p "$dest"
        for item in "$src"/.* "$src"/*; do
            [ -e "$item" ] || continue
            base="$(basename "$item")"
            [ "$base" = "." ] || [ "$base" = ".." ] && continue
            copy_config "$item" "$dest/$base"
        done
        return
    fi

    mkdir -p "$(dirname "$dest")"

    # New file — just copy
    if [ ! -f "$dest" ]; then
        cp "$src" "$dest"
        success "Installed $rel"
        return
    fi

    # Identical — nothing to do
    if diff -q "$src" "$dest" &>/dev/null; then
        success "$rel unchanged"
        return
    fi

    # Different — show diff and ask
    echo ""
    echo -e "${YELLOW}── diff: $rel ──────────────────────────────────────${RESET}"
    diff --color=always "$dest" "$src" || true
    echo -e "${YELLOW}────────────────────────────────────────────────────${RESET}"
    printf "  Overwrite %s with repo version? [y/N] " "$rel"
    read -r answer </dev/tty
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        cp "$src" "$dest"
        success "Updated $rel"
    else
        warn "Skipped $rel"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BOLD}${CYAN}"
echo "  ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗"
echo "  ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝"
echo "  ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗"
echo "  ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║"
echo "  ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║"
echo "  ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝"
echo -e "${RESET}"
echo "  Installing dotfiles from: $DOTFILES_DIR"
echo ""

# ── 1. System packages ────────────────────────────────────────────────────────
header "1. System packages"
for pkg in git zsh curl vim; do
    install_pkg "$pkg"
done

# ── 2. oh-my-zsh ─────────────────────────────────────────────────────────────
header "2. oh-my-zsh"
clone_or_update \
    "https://github.com/ohmyzsh/ohmyzsh.git" \
    "$HOME/.oh-my-zsh" \
    "oh-my-zsh"

# ── 3. zsh plugins ───────────────────────────────────────────────────────────
header "3. zsh plugins"
OMZ_PLUGINS="$HOME/.oh-my-zsh/custom/plugins"
clone_or_update \
    "https://github.com/zsh-users/zsh-autosuggestions" \
    "$OMZ_PLUGINS/zsh-autosuggestions" \
    "zsh-autosuggestions"
clone_or_update \
    "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "$OMZ_PLUGINS/zsh-syntax-highlighting" \
    "zsh-syntax-highlighting"

# ── 4. fzf ───────────────────────────────────────────────────────────────────
header "4. fzf"
clone_or_update \
    "https://github.com/junegunn/fzf.git" \
    "$HOME/.fzf" \
    "fzf"
if [ ! -f "$HOME/.fzf.zsh" ]; then
    info "Running fzf install..."
    "$HOME/.fzf/install" --all --no-update-rc
    success "fzf installed"
else
    success "fzf already set up"
fi

# ── 5. vim-plug ───────────────────────────────────────────────────────────────
header "5. vim-plug"
PLUG_PATH="$HOME/.vim/autoload/plug.vim"
if [ -f "$PLUG_PATH" ]; then
    success "vim-plug already installed"
else
    info "Installing vim-plug..."
    curl -fLo "$PLUG_PATH" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    success "vim-plug installed"
fi

# ── 6. Deploy config files ────────────────────────────────────────────────────
header "6. Config files"
for item in "$DEPLOY_DIR"/.*; do
    [ -e "$item" ] || continue
    base="$(basename "$item")"
    [ "$base" = "." ] || [ "$base" = ".." ] && continue
    copy_config "$item" "$HOME/$base"
done

# ── 7. vim plugins ────────────────────────────────────────────────────────────
header "7. vim plugins"
info "Running vim +PlugInstall..."
vim -E -s -u "$HOME/.vimrc" +PlugInstall +qall 2>/dev/null || true
success "vim plugins installed"

# ── 8. Default shell ──────────────────────────────────────────────────────────
header "8. Default shell"
ZSH_PATH="$(command -v zsh)"
if [ "$SHELL" = "$ZSH_PATH" ]; then
    success "zsh is already the default shell"
else
    info "Changing default shell to zsh..."
    if grep -qx "$ZSH_PATH" /etc/shells; then
        chsh -s "$ZSH_PATH"
        success "Default shell changed to zsh (takes effect on next login)"
    else
        warn "zsh not in /etc/shells, adding it..."
        echo "$ZSH_PATH" | sudo tee -a /etc/shells
        chsh -s "$ZSH_PATH"
        success "Default shell changed to zsh"
    fi
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}Installation complete!${RESET}"
echo ""
echo -e "${BOLD}Restart your shell or run:${RESET}  exec zsh"
echo ""
echo -e "${BOLD}Optional tools (install manually if needed):${RESET}"
echo "  • atuin   — https://atuin.sh  (shell history sync)"
echo "  • glab    — https://gitlab.com/gitlab-org/cli  (GitLab CLI)"
echo "  • gcloud  — https://cloud.google.com/sdk/docs/install  (Google Cloud SDK)"
echo "  • vscode  — https://code.visualstudio.com  (editor)"
echo ""
