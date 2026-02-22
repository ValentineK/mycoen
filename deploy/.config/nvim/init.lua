-- ── Bootstrap lazy.nvim ───────────────────────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Status line
    {
        "nvim-lualine/lualine.nvim",
        opts = {
            options = { theme = "auto" },
            tabline = { lualine_a = { "buffers" } },
        },
    },

    -- Git
    { "tpope/vim-fugitive" },
    { "junegunn/gv.vim" },
    {
        "lewis6991/gitsigns.nvim",
        event = "BufReadPre",
        opts = {
            current_line_blame = false,
        },
        keys = {
            { "<Leader>s", "<cmd>Gitsigns blame_line<cr>" },
        },
    },

    -- Multi-cursor
    { "mg979/vim-visual-multi", branch = "master" },

    -- Fuzzy finder
    {
        "ibhagwan/fzf-lua",
        keys = {
            { "<leader>ff", "<cmd>FzfLua files<cr>",    desc = "Find files" },
            { "<leader>fg", "<cmd>FzfLua live_grep<cr>",  desc = "Live grep" },
            { "<leader>fG", "<cmd>FzfLua grep<cr>",      desc = "Fuzzy grep" },
            { "<leader>fb", "<cmd>FzfLua buffers<cr>",  desc = "Buffers" },
        },
    },

    -- Keybinding hints
    { "folke/which-key.nvim", event = "VeryLazy", opts = {} },

    -- Syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        lazy  = false,
        build = ":TSUpdate",
        opts = {
            ensure_installed = {
                "lua", "python", "javascript", "typescript", "tsx",
                "bash", "ruby", "terraform", "hcl", "dockerfile", "yaml", "json",
                "rust",
            },
        },
    },

    -- LSP servers + completion
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            { "williamboman/mason.nvim",    opts = {} },
            { "neovim/nvim-lspconfig" },
        },
        opts = {
            ensure_installed = {
                "lua_ls", "pyright", "ts_ls", "bashls",
                "terraformls", "dockerls", "yamlls", "rust_analyzer",
            },
            handlers = {
                function(server_name)
                    require("lspconfig")[server_name].setup({})
                end,
            },
        },
    },
    {
        "saghen/blink.cmp",
        version = "*",
        opts = {
            keymap  = { preset = "default" },
            sources = { default = { "lsp", "path", "snippets", "buffer" } },
        },
    },

    -- Claude Code integration
    {
        "greggh/claude-code.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
    },

    -- Colorscheme
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = { flavour = "mocha" },
        init = function()
            vim.cmd.colorscheme("catppuccin")
        end,
    },
})

-- ── Basic settings ─────────────────────────────────────────────────────────────
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
