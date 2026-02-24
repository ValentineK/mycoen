#!/usr/bin/env bash
set -euo pipefail

# Install/update optional local apps to ~/.local/
# Usage:
#   ./install/apps.sh            # install/update all
#   ./install/apps.sh glab       # install/update specific app(s)
#   ./install/apps.sh glab tfenv

# ── Colors ─────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[•]${RESET} $*"; }
success() { echo -e "${GREEN}[✓]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[!]${RESET} $*"; }
error()   { echo -e "${RED}[✗]${RESET} $*" >&2; }
header()  { echo -e "\n${BOLD}── $* ──${RESET}"; }

LOCAL_BIN="$HOME/.local/bin"
LOCAL_SRC="$HOME/.local/src"
mkdir -p "$LOCAL_BIN" "$LOCAL_SRC"

ARCH="$(uname -m)"

# ── glab ───────────────────────────────────────────────────────────────────────
install_glab() {
    header "glab"
    case "$ARCH" in
        x86_64)  local arch="amd64" ;;
        aarch64) local arch="arm64" ;;
        *) error "Unsupported arch for glab: $ARCH"; return 1 ;;
    esac

    local latest
    latest="$(curl -fsSL 'https://gitlab.com/api/v4/projects/gitlab-org%2Fcli/releases?per_page=1' \
        | python3 -c 'import sys,json; print(json.load(sys.stdin)[0]["tag_name"][1:])')"

    if command -v glab &>/dev/null; then
        local current
        current="$(glab --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
        if [ "$current" = "$latest" ]; then
            success "glab already at v$latest"
            return
        fi
        info "Updating glab $current → $latest"
    else
        info "Installing glab v$latest..."
    fi

    local url="https://gitlab.com/api/v4/projects/gitlab-org%2Fcli/packages/generic/glab/${latest}/glab_${latest}_linux_${arch}.tar.gz"
    local tmp; tmp="$(mktemp -d)"
    curl -fLo "$tmp/glab.tar.gz" "$url"
    tar -C "$tmp" -xzf "$tmp/glab.tar.gz"
    local binary; binary="$(find "$tmp" -name "glab" -type f | head -1)"
    cp "$binary" "$LOCAL_BIN/glab"
    chmod +x "$LOCAL_BIN/glab"
    rm -rf "$tmp"
    success "glab v$latest → $LOCAL_BIN/glab"
}

# ── gcloud ─────────────────────────────────────────────────────────────────────
install_gcloud() {
    header "gcloud"
    if [ -d "$LOCAL_SRC/google-cloud-sdk" ]; then
        info "Updating gcloud components..."
        "$LOCAL_SRC/google-cloud-sdk/bin/gcloud" components update --quiet
        success "gcloud updated"
        return
    fi
    info "Installing gcloud to $LOCAL_SRC/google-cloud-sdk..."
    curl -fsSL https://sdk.cloud.google.com \
        | CLOUDSDK_CORE_DISABLE_PROMPTS=1 bash -s -- --disable-prompts --install-dir="$LOCAL_SRC"
    success "gcloud installed → $LOCAL_SRC/google-cloud-sdk"
}

# ── tfenv ──────────────────────────────────────────────────────────────────────
install_tfenv() {
    header "tfenv"
    if [ -d "$LOCAL_SRC/tfenv/.git" ]; then
        info "Updating tfenv..."
        git -C "$LOCAL_SRC/tfenv" pull --ff-only 2>&1 | tail -1
        success "tfenv up to date"
        return
    fi
    info "Installing tfenv to $LOCAL_SRC/tfenv..."
    git clone --depth=1 https://github.com/tfutils/tfenv.git "$LOCAL_SRC/tfenv"
    success "tfenv installed → $LOCAL_SRC/tfenv"
}

# ── atuin ──────────────────────────────────────────────────────────────────────
install_atuin() {
    header "atuin"
    if command -v atuin &>/dev/null; then
        success "atuin already installed ($(atuin --version))"
        return
    fi
    info "Installing atuin..."
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
    success "atuin installed"
}

# ── main ───────────────────────────────────────────────────────────────────────
ALL_APPS=(glab gcloud tfenv atuin)

REQUESTED=("$@")
if [ ${#REQUESTED[@]} -eq 0 ]; then
    REQUESTED=("${ALL_APPS[@]}")
fi

for app in "${REQUESTED[@]}"; do
    case "$app" in
        glab)   install_glab   ;;
        gcloud) install_gcloud ;;
        tfenv)  install_tfenv  ;;
        atuin)  install_atuin  ;;
        *) error "Unknown app: $app (available: ${ALL_APPS[*]})"; exit 1 ;;
    esac
done

echo ""
echo -e "${GREEN}${BOLD}Done.${RESET}"
