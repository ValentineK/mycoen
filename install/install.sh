#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEPLOY_DIR="$DOTFILES_DIR/deploy"

# ── Flags ─────────────────────────────────────────────────────────────────────
QUIET=false
for arg in "$@"; do
    case "$arg" in
        -q|--quiet) QUIET=true ;;
    esac
done

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

# ── Install starship from GitHub releases ─────────────────────────────────────
install_starship() {
    local local_bin="$HOME/.local/bin"
    mkdir -p "$local_bin"

    local latest
    latest="$(curl -fsSL 'https://api.github.com/repos/starship/starship/releases/latest' \
        | python3 -c 'import sys,json; print(json.load(sys.stdin)["tag_name"][1:])')"

    if command -v starship &>/dev/null; then
        local current
        current="$(starship --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
        if [ "$current" = "$latest" ]; then
            success "starship already at v$latest"
            return
        fi
        info "Updating starship $current → $latest"
    else
        info "Installing starship v$latest..."
    fi

    curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$local_bin" --yes
    success "starship v$latest installed"
}

# ── Install neovim from GitHub releases ───────────────────────────────────────
install_neovim() {
    local min_major=0 min_minor=8
    if command -v nvim &>/dev/null; then
        local version major minor
        version="$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
        major="$(echo "$version" | cut -d. -f1)"
        minor="$(echo "$version" | cut -d. -f2)"
        if [ "$major" -gt "$min_major" ] || { [ "$major" -eq "$min_major" ] && [ "$minor" -ge "$min_minor" ]; }; then
            success "neovim already installed (v$version)"
            return
        fi
        warn "neovim v$version is too old (need >= $min_major.$min_minor), reinstalling..."
    fi
    if command -v brew &>/dev/null; then
        info "Installing neovim via brew..."
        brew install neovim
        return
    fi
    local arch
    arch="$(uname -m)"
    case "$arch" in
        x86_64)  local tarball="nvim-linux-x86_64.tar.gz" ;;
        aarch64) local tarball="nvim-linux-arm64.tar.gz" ;;
        *)
            error "Unsupported architecture: $arch"
            return 1
            ;;
    esac
    local url="https://github.com/neovim/neovim/releases/latest/download/$tarball"
    local tmp
    tmp="$(mktemp -d)"
    info "Downloading neovim ($arch)..."
    curl -fLo "$tmp/$tarball" "$url"
    info "Installing to /usr/local..."
    sudo tar -C /usr/local --strip-components=1 -xzf "$tmp/$tarball"
    rm -rf "$tmp"
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

    # Different — show diff and ask (or auto-overwrite in quiet mode)
    if $QUIET; then
        cp "$src" "$dest"
        success "Updated $rel"
        return
    fi
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
for pkg in git zsh curl vim tmux; do
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

# ── 5. tmux plugin manager (TPM) ─────────────────────────────────────────────
header "5. tmux plugin manager"
clone_or_update \
    "https://github.com/tmux-plugins/tpm" \
    "$HOME/.tmux/plugins/tpm" \
    "tpm"

# ── 6. vim-plug ───────────────────────────────────────────────────────────────
header "6. vim-plug"
PLUG_PATH="$HOME/.vim/autoload/plug.vim"
if [ -f "$PLUG_PATH" ]; then
    success "vim-plug already installed"
else
    info "Installing vim-plug..."
    curl -fLo "$PLUG_PATH" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    success "vim-plug installed"
fi

# ── 7. Deploy config files ────────────────────────────────────────────────────
header "7. Config files"
for item in "$DEPLOY_DIR"/.*; do
    [ -e "$item" ] || continue
    base="$(basename "$item")"
    [ "$base" = "." ] || [ "$base" = ".." ] && continue
    copy_config "$item" "$HOME/$base"
done

# ── 8. tmux plugins ───────────────────────────────────────────────────────────
header "8. tmux plugins"
if command -v tmux &>/dev/null; then
    info "Installing tmux plugins via TPM..."
    "$HOME/.tmux/plugins/tpm/bin/install_plugins" 2>/dev/null || true
    success "tmux plugins installed"
else
    warn "tmux not found, skipping plugin install"
fi

# ── 10. vim plugins ───────────────────────────────────────────────────────────
header "10. vim plugins"
info "Running vim +PlugInstall..."
vim -E -s -u "$HOME/.vimrc" +PlugInstall +qall 2>/dev/null || true
success "vim plugins installed"

# ── 11. neovim (optional) ─────────────────────────────────────────────────────
header "11. neovim (optional)"
if $QUIET; then
    info "Skipping neovim (quiet mode)"
else
    printf "  Install neovim? [y/N] "
    read -r answer </dev/tty
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        install_neovim
        install_pkg ripgrep
        # node + npm — required by Mason for pyright and ts_ls
        if command -v node &>/dev/null && command -v npm &>/dev/null; then
            success "node already installed ($(node --version))"
        else
            info "Installing node + npm (required for Mason LSP servers)..."
            if command -v brew &>/dev/null; then
                brew install node
            elif command -v apt-get &>/dev/null; then
                sudo apt-get install -y nodejs npm
            elif command -v dnf &>/dev/null; then
                sudo dnf install -y nodejs npm
            elif command -v pacman &>/dev/null; then
                sudo pacman -S --noconfirm nodejs npm
            else
                warn "Cannot install node/npm: no supported package manager found"
            fi
        fi
        # tree-sitter-cli — required by nvim-treesitter to compile parsers
        if command -v tree-sitter &>/dev/null; then
            success "tree-sitter-cli already installed ($(tree-sitter --version))"
        else
            info "Installing tree-sitter-cli..."
            # glibc < 2.39 requires pinned version 0.22.6
            local glibc_minor
            glibc_minor="$(ldd --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+$' | cut -d. -f2 || echo 99)"
            if [ "$glibc_minor" -lt 39 ] 2>/dev/null; then
                sudo npm install -g tree-sitter-cli@0.22.6
            else
                sudo npm install -g tree-sitter-cli
            fi
            success "tree-sitter-cli installed"
        fi
        success "neovim ready — run 'nvim' to start"
    else
        info "Skipping neovim"
    fi
fi

# ── 12. starship ──────────────────────────────────────────────────────────────
header "12. starship"
install_starship

# ── 13. Default shell ─────────────────────────────────────────────────────────
header "13. Default shell"
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
echo -e "${BOLD}Optional tools — install via apps.sh:${RESET}"
echo "  ./install/apps.sh               # install all"
echo "  ./install/apps.sh glab gcloud   # install specific"
echo ""
echo -e "${BOLD}Apps managed by apps.sh:${RESET}"
echo "  • glab   • gcloud   • tfenv   • atuin"
echo ""
echo -e "${BOLD}Install separately:${RESET}"
echo "  • claude  — https://claude.ai/code  (self-updates via: claude update)"
echo "  • vscode  — https://code.visualstudio.com"
echo ""
