#!/usr/bin/env sh
set -e

DOTFILES_REPO="https://github.com/ValentineK/mycoen.git"
DOTFILES_DIR="$HOME/.dotfiles"

if [ -d "$DOTFILES_DIR/.git" ]; then
    echo "[•] Updating dotfiles..."
    git -C "$DOTFILES_DIR" pull --ff-only
else
    echo "[•] Cloning dotfiles..."
    git clone --depth=1 "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

exec bash "$DOTFILES_DIR/install/install.sh" "$@"
