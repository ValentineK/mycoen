# neovim config

Lua config with [lazy.nvim](https://github.com/folke/lazy.nvim) as plugin manager. Plugins install automatically on first `nvim` launch.

## Plugins

| Plugin | Purpose |
|--------|---------|
| lualine.nvim | Status line + buffer tabline |
| vim-fugitive | Git integration (`:Git`) |
| gv.vim | Git commit log (`:GV`) |
| gitsigns.nvim | Git hunk signs + line blame |
| vim-visual-multi | Multi-cursor |
| fzf-lua | Fuzzy file/grep search (uses system fzf) |
| which-key.nvim | Keybinding hints on pause |

## Leader key

Default leader is `\`. To change to space, add before `require("lazy")`:

```lua
vim.g.mapleader = " "
```

## Keybindings

| Key | Action |
|-----|--------|
| `\s` | Git blame current line |
| `\ff` | Fuzzy find files |
| `\fg` | Live grep (exact/regex via ripgrep) |
| `\fG` | Fuzzy grep |
| `\fb` | Switch buffers |

## Git workflow (fugitive)

1. `:Git` — open status window
2. `=` — expand inline diff for file under cursor
3. `s` — stage file or visual-selected lines
4. `u` — unstage
5. `cc` — open commit message buffer, `:wq` to commit
6. `:Git push` — push
7. `:GV` — browse commit log

## Editing

| Key | Action |
|-----|--------|
| `u` | Undo |
| `Ctrl+r` | Redo |
| `Ctrl+Z` | Suspend nvim (run `fg` to return) |

## Windows & terminal

| Key / Command | Action |
|---------------|--------|
| `Ctrl+w h/j/k/l` | Move between splits |
| `Ctrl+w w` | Cycle windows |
| `:terminal` | Open terminal inside nvim |
| `Ctrl+\ Ctrl+n` | Exit terminal insert mode |

## Plugin management

| Command | Action |
|---------|--------|
| `:Lazy` | Open lazy.nvim UI |
| `:Lazy sync` | Install / update plugins |
