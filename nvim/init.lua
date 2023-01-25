-- Description -----------------------------------------------------------------
-- My single file Neovim config.
-- Ben Ewing on 2023-01-17

-- Options ---------------------------------------------------------------------
-- Show line numbers by default
vim.wo.number = true

-- Make tabs two characters long
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

-- Split windows to the right (when splitting vertically) or below (when
-- splitting horizontally)
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Allow nicer colors (for nicer colorschemes)
vim.o.termguicolors = true

-- Use the system clipboard
vim.opt.clipboard = "unnamedplus"

-- Prevent neovim from creating various files
vim.opt.swapfile = false

-- Enforce utf-8 file encoding, utf-8 is the default, but this will force
vim.opt.fileencoding = "utf-8"

-- Ignore case when searching, unless uppercase letters are explicitly used
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- prevent cursor from reaching the bottom of the screen until reaching the
-- end of the buffer
vim.opt.scrolloff = 8

-- Keep space in the gutter for diagnostic flags
vim.opt.signcolumn = 'yes'

-- Allow which-key to respond quickly
vim.o.timeoutlen = 300

-- Plugin configurations -------------------------------------------------------
-- Configs come before actual plugins so we can use the config functions in lazy

-- LSP setup
local lsp_zero_setup = function()
	local lspz = require("lsp-zero")

	-- This is lsp-zero's recommended set of preferences, see more on GitHub
	lspz.preset("recommended")

	-- Install language servers via Mason/lspconfig
	lspz.ensure_installed({
		"clangd", "cssls", "dockerls", "gopls", "html", "jsonls", "pyright",
		"r_language_server", "rust_analyzer", "sumneko_lua", "yamlls", "zls"
	})

	-- Configure cmp
	-- This sets up sources other than the defaults (vim-dadbod, nvimr), and
	-- changes select behavior so that cmp suggestions aren't accepted
	-- by default (i.e. you need to hit tab once to use a cmp suggestion).
	-- local cmp = require("cmp")
	lspz.setup_nvim_cmp({
		sources = {
			{ name = 'nvim_lsp', keyword_length = 2 },
			-- { name = 'cmp_nvim_r', keyword_length = 2 },
			-- { name = 'vim-dadbod-completion', keyword_length = 2 },
			{ name = 'buffer', keyword_length = 3 },
			{ name = 'path', keyword_length = 3 },
			{ name = 'luasnip', keyword_length = 3 },
		}
	})

	-- Configure lsp-zero for neovim development
	lspz.nvim_workspace()

	lspz.setup()
end

-- which-key setup
local which_key_setup = function()
	local wk = require("which-key")

	wk.setup()

	wk.register({
		["<leader>"] = {
			f = {
				name = "Find"
			}
		}
	})
end

-- lualine setup
local lualine_setup = function()
	local ll = require("lualine")

	ll.setup({
		options = {
			globalstatus = true,
			icons_enabled = true,
			theme = "auto",
			always_divide_middle = true,
		},
		sections = {
			-- left
			lualine_a = { "mode" },
			lualine_b = { "branch" },
			lualine_c = { "diff" },
			-- right
			lualine_x = { "filetype" },
			lualine_y = { "location" },
			lualine_z = { "progress" }
		}
	})
end

-- treesitter setup
local treesitter_setup = function ()
	require("nvim-treesitter.configs").setup({
		ensure_installed = { "bash", "c", "css", "dockerfile", "go", "jq", "json", "lua",
												 "markdown", "python", "r", "rust", "sql", "zig" },
		highlight = {
			enable = true
		},
		indent = {
			enable = true
		},
		context_commentstring = {
			enable = true
		}
	})
end
-- Plugins ---------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	-- Colorschemes
	-- lazy loading means that these won't show up live when typing :colorscheme,
	-- but they will load without error
	{ "folke/tokyonight.nvim", lazy = true },
	{ "nsgrantham/poolside-vim", lazy = true },
	{ "catppuccin/nvim", lazy = true, name = "catppuccin" },

	-- Easy comment toggling
	"numToStr/Comment.nvim",

	-- Easily surround selection
	"machakann/vim-sandwich",

	-- Close buffers without closing windows
	"famiu/bufdelete.nvim",

	-- File tree, lazy load when toggling
	{
		"nvim-neo-tree/neo-tree.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim"
		},
		cmd = "NeoTreeFloatToggle",
		config = true
	},

	-- Terminal, lazy load when toggling
	{
		"akinsho/toggleterm.nvim",
		cmd = "ToggleTerm",
		config = function()
			require("toggleterm").setup({
				direction = "float",
			})
		end
	},

	-- Fuzzy finder
	-- TODO telescope + LSP?
	-- TODO lazy load this
	"nvim-telescope/telescope.nvim",

	-- LSP/Autocomplete
	{
		"VonHeikemen/lsp-zero.nvim",
		dependencies = {
			-- LSP
			"neovim/nvim-lspconfig",
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			-- Autocomplete
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			-- Snippets, I don't really use these, but required by lsp-zero
			"L3MON4D3/LuaSnip"
		},
		event = "InsertEnter",
		config = lsp_zero_setup
	},

	-- treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		config = treesitter_setup
	},

	-- A nice bufferline at the top
	{
  	"akinsho/bufferline.nvim",
		config = true
	},
	-- A nice status line on the bottom 
	{
    "nvim-lualine/lualine.nvim",
    config = lualine_setup
  },
	-- Key mapping hits
	{
		"folke/which-key.nvim",
		config = which_key_setup
	},
})

-- Set color scheme ------------------------------------------------------------
-- Setting the colorscheme after lazy.nvim means that any lazy.nvim updates
-- (or other delays in startup) will show the default colorscheme first, but
-- this avoids an error when trying to load an uninstalled colorscheme on
-- startup.
-- vim.cmd.colorscheme("catppuccin")
vim.cmd.colorscheme("tokyonight-night")

-- Keymaps ---------------------------------------------------------------------
-- Set the leader key
vim.keymap.set("", "<Space>", "<Nop>", { silent = true })
vim.g.mapleader = " "

-- Toggle NeoTree
vim.keymap.set("n", "<leader>e", "<cmd>NeoTreeFloatToggle<cr>", { silent = true, desc = "Toggle file explorer" })

-- Toggle terminal, in every mode
-- I'd prefer to map this to <leader>t to match NeoTree, but this is practical
vim.keymap.set("n", [[<c-\>]], "<cmd>ToggleTerm<cr>", { silent = true, desc = "Toggle terminal" })
vim.keymap.set("i", [[<c-\>]], "<cmd>ToggleTerm<cr>", { silent = true, desc = "Toggle terminal" })
vim.keymap.set("t", [[<c-\>]], "<cmd>ToggleTerm<cr>", { silent = true, desc = "Toggle terminal" })

--Fuzzy finder
local tbuiltin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', tbuiltin.find_files, { silent = true, desc = "Files" })
vim.keymap.set('n', '<leader>fg', tbuiltin.live_grep, { silent = true, desc = "Grep" })
vim.keymap.set('n', '<leader>fb', tbuiltin.buffers, { silent = true, desc = "Buffer" })
vim.keymap.set('n', '<leader>fh', tbuiltin.help_tags, { silent = true, desc = "Help" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { silent = true })

-- Buffer navigation
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { silent = true })
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { silent = true })

-- Manage buffers
vim.keymap.set("n", "<leader>c", "<cmd>Bdelete!<CR>", { silent = true, desc = "Close buffer" })

-- Adjust indentation without leaving visual mode
vim.keymap.set("v", "<", "<gv", { silent = true })
vim.keymap.set("v", ">", ">gv", { silent = true })

-- Toggle comments
vim.keymap.set("n", "<leader>/", "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>",
	{ silent = true, desc = "Toggle comment" })
vim.keymap.set("x", "<leader>/", '<ESC><CMD>lua require("Comment.api").toggle.linewise(vim.fn.visualmode())<CR>',
	{ silent = true, desc = "Toggle comment" })

-- Autocommands ----------------------------------------------------------------
-- Exit quickfix/help/man/lspinfo windows by hitting q
vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = { "qf", "help", "man", "lspinfo", "telescope" },
	callback = function()
		vim.keymap.set("n", "q", "<cmd>close<cr>", { noremap = true, silent = true, buffer = 0 })
	end,
})

-- TODO toggle relative colors
-- TODO toggle light/dark themes
