-- Managed by chezmoi: https://www.chezmoi.io/

-- Must be set before any plugin that replaces netrw (e.g. nvim-tree)
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- =============================================================================
-- Options
-- =============================================================================
vim.opt.tabstop      = 4
vim.opt.softtabstop  = 4
vim.opt.expandtab    = true
vim.opt.shiftwidth   = 4
vim.opt.shiftround   = true
vim.opt.copyindent   = true
vim.opt.number       = true
vim.opt.showmatch    = true
vim.opt.ignorecase   = true
vim.opt.smartcase    = true
vim.opt.scrolloff    = 4
vim.opt.virtualedit  = "all"
vim.opt.gdefault     = true
vim.opt.list         = false
vim.opt.listchars    = { tab = "▸ ", trail = "·", extends = "#", nbsp = "·" }
vim.opt.fileformats  = { "unix", "dos", "mac" }
vim.opt.clipboard    = "unnamedplus"
vim.opt.autoread     = true
vim.opt.updatetime   = 1000
vim.opt.termguicolors = true
vim.opt.shortmess:append("I")

-- =============================================================================
-- Bootstrap lazy.nvim
-- =============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- =============================================================================
-- Plugins
-- =============================================================================
require("lazy").setup({

    -- Colorscheme: onehalfdark
    {
        "sonph/onehalf",
        config = function(plugin)
            vim.opt.rtp:append(plugin.dir .. "/vim")
            vim.cmd("colorscheme onehalfdark")
        end,
    },

    -- Fuzzy finder: telescope with fzf native algorithm
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        config = function()
            require("telescope").load_extension("fzf")
        end,
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>",  desc = "Find files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>",   desc = "Live grep" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>",     desc = "Buffers" },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>",   desc = "Help tags" },
        },
    },

    -- File explorer
    {
        "nvim-tree/nvim-tree.lua",
        opts = { filters = { dotfiles = false } },
        keys = { { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "File explorer" } },
    },

    -- Syntax highlighting
    -- main branch requires Neovim 0.12+ and the tree-sitter CLI (brew install
    -- tree-sitter-cli); it doesn't support lazy-loading, hence lazy = false.
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build  = ":TSUpdate",
        lazy   = false,
        config = function()
            local langs = {
                "bash", "dockerfile", "go", "hcl", "json",
                "lua", "python", "rust", "terraform", "yaml",
            }
            require("nvim-treesitter").install(langs)
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "sh", "bash", "dockerfile", "go", "hcl", "json",
                            "lua", "python", "rust", "terraform", "yaml" },
                callback = function()
                    vim.treesitter.start()
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
        end,
    },

    -- Statusline
    {
        "nvim-lualine/lualine.nvim",
        opts = { options = { theme = "auto" } },
    },

    -- Bracket pairing
    { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
})
