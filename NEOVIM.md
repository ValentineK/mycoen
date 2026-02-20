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
| catppuccin | Colorscheme (mocha flavour) |
| nvim-treesitter | Syntax highlighting + indentation |
| mason.nvim | LSP server installer |
| mason-lspconfig | Wires mason servers into lspconfig |
| nvim-lspconfig | LSP client config |
| blink.cmp | Completion engine |

## LSP servers

Installed automatically by Mason on first launch:

| Server | Language |
|--------|----------|
| `lua_ls` | Lua |
| `pyright` | Python |
| `ts_ls` | JavaScript / TypeScript |
| `bashls` | Bash / Shell |
| `ruby_lsp` | Ruby |
| `terraformls` | Terraform / HCL |
| `dockerls` | Dockerfile |
| `yamlls` | YAML |
| `rust_analyzer` | Rust |

**Useful LSP commands:**

| Command / Key | Action |
|---------------|--------|
| `K` | Hover documentation |
| `gd` | Go to definition |
| `gr` | Go to references |
| `:LspInfo` | Show active LSP for current file |
| `:Mason` | Open Mason UI to manage servers |

## Completion (blink.cmp)

| Key | Action |
|-----|--------|
| `Tab` / `S-Tab` | Navigate suggestions |
| `Enter` | Confirm selection |

Sources: LSP, path, snippets, buffer.

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
