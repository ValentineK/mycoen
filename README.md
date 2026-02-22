# dotfiles

Personal shell configuration for zsh + vim.

## Structure

```
deploy/       config files copied to ~
install/      installer script
```

**Deployed configs:** `.zshrc`, `.vimrc`, `.profile`, `.gitconfig`, `.gitignore`, `.atuin/config.toml`, `.zshrc.d/` (atuin, fzf, gcloud, glab, glop, vscode)

## Install

```sh
git clone <repo-url> ~/.dotfiles
~/.dotfiles/install/install.sh
```

Installs: `zsh`, `oh-my-zsh`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `fzf`, `vim-plug` + vim plugins, sets zsh as default shell.

## Update

Re-run the script on an existing machine:

```sh
~/.dotfiles/install/install.sh
```

- Git repos (oh-my-zsh, fzf, plugins) — pulls latest, warns on remote mismatch
- Config files — shows diff and asks before overwriting

## Optional tools

Configs for these are deployed but tools must be installed separately:

| Tool | URL |
|------|-----|
| atuin | https://atuin.sh |
| glab | https://gitlab.com/gitlab-org/cli |
| gcloud | https://cloud.google.com/sdk/docs/install |
| vscode | https://code.visualstudio.com |

## Vim plugins

Managed by [vim-plug](https://github.com/junegunn/vim-plug). Installed automatically by the script. To update manually: `:PlugUpdate` inside vim.

| Plugin | Purpose |
|--------|---------|
| vim-airline | Status/tabline |
| vim-fugitive + gv.vim | Git integration |
| git-blame.vim | Line blame (`\s`) |
| vim-visual-multi | Multi-cursor |

## Neovim

Lua config at `deploy/.config/nvim/init.lua`, managed by [lazy.nvim](https://github.com/folke/lazy.nvim). Plugins install automatically on first launch.

Includes: catppuccin theme, treesitter highlighting, LSP (mason + lspconfig), blink.cmp completions, fzf-lua, gitsigns, which-key.

**Requirement:** treesitter parsers are compiled via `tree-sitter-cli`. Install it once manually:

```sh
sudo npm install -g tree-sitter-cli@0.22.6
```

> On systems with glibc < 2.39 (e.g. Raspberry Pi / Debian 12), pin to `0.22.6` — newer versions require glibc 2.39.

**LSP servers:** `lua_ls`, `pyright`, `ts_ls`, `bashls`, `ruby_lsp`, `terraformls`, `dockerls`, `yamlls`, `rust_analyzer`

See [NEOVIM.md](NEOVIM.md) for keybindings and usage.
