-- Description -------------------------------------------------------------------------------------
-- My Neovim config.
-- Ben Ewing on 2023-01-05

-- Options ----------------------------------------------------------------------------------------
-- Aesthetic
vim.opt.cmdheight = 1
vim.opt.pumheight = 10
vim.opt.showmode = false
vim.opt.showtabline = 2
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 4
vim.opt.laststatus = 3
vim.opt.ruler = false
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.fillchars.eob = " "

-- Editor
vim.opt.completeopt = { "menuone", "noselect", "noinsert" }
vim.opt.conceallevel = 0
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.shortmess:append "c"
-- vim.opt.whichwrap:append("h,l")
vim.opt.iskeyword:remove("-,_")
vim.opt.formatoptions:remove({ "c", "r", "o" })

-- MacOS Interop
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"

-- Search
vim.opt.hlsearch = true
vim.opt.ignorecase = true

-- Misc Files
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.undofile = false

-- Odds and Ends
vim.opt.fileencoding = "utf-8"
vim.opt.timeoutlen = 500
vim.opt.updatetime = 250
vim.opt.writebackup = false
vim.opt.showcmd = false

-- Plugins ----------------------------------------------------------------------------------------
-- Bootstrap lazy.nvim
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
  -- Color themes
  {
    "folke/tokyonight.nvim",
    config = function()
      vim.cmd([[colorscheme tokyonight]])
    end
  },
  "nsgrantham/poolside-vim",

  -- Text editing
  "numToStr/Comment.nvim",
  "machakann/vim-sandwich",

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path"
    },
  },

  -- LSP
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
    },
    config = true
  },
  "L3MON4D3/LuaSnip",
  "VonHeikemen/lsp-zero.nvim",

  -- Treesitter/syntax highlighting
  "nvim-treesitter/nvim-treesitter",

  -- Filesystem
  {
    "nvim-tree/nvim-tree.lua"
  },

  -- Editor info
  {
    "folke/which-key.nvim",
    lazy = true
  },
  {
    "nvim-lualine/lualine.nvim",
    lazy = true
  },
  {
    "akinsho/bufferline.nvim",
    config = true
  },
  "RRethy/vim-illuminate",

  -- Terminal tools
  {
    "akinsho/toggleterm.nvim",
    lazy = true
  },

  -- R
  {
    "jalvesaq/Nvim-R",
    dependencies = {
      "jalvesaq/cmp-nvim-r",
    },
    -- TODO make this lazy
  },

  -- Database tools
  {
    "tpope/vim-dadbod",
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",
      "kristijanhusak/vim-dadbod-completion",
    },
    -- TODO make this lazy
  }

  -- TODO make dbui window floating
})

-- lsp --------------------------------------------------------------------------------------------
local lsp = require("lsp-zero")
-- Ask lsp-zero to configure cmp, and..everything else needed for lsp completion.
lsp.set_preferences({
  suggest_lsp_servers = true,
  setup_servers_on_start = true,
  set_lsp_keymaps = true,
  configure_diagnostics = true,
  cmp_capabilities = true,
  manage_nvim_cmp = true,
  call_servers = 'local',
  sign_icons = {
    error = 'x',
    warn = 'w',
    hint = 'h',
    info = 'i'
  },
})

-- Ask Mason/lspconfig/lsp-zero to install servers
lsp.ensure_installed({ "clangd", "cssls", "dockerls", "gopls", "html", "jsonls", "pyright",
  "r_language_server", "rust_analyzer", "sumneko_lua", "yamlls", "zls" })

-- Add cmp-nvim-r to cmp sources
lsp.setup_nvim_cmp({
  sources = {
    { name = 'path' },
    { name = 'nvim_lsp', keyword_length = 3 },
    { name = 'cmp_nvim_r', keyword_length = 3 },
    { name = 'vim-dadbod-completion', keyword_length = 3 },
    { name = 'buffer', keyword_length = 3 },
    { name = 'luasnip', keyword_length = 2 },
  }
})

-- Set up the lua language server for nvim development
lsp.nvim_workspace()

-- Configure language server
lsp.setup()

-- treesitter -------------------------------------------------------------------------------------
require("nvim-treesitter.configs").setup({
  ensure_installed = { "arduino", "bash", "c", "css", "dockerfile", "go", "jq", "json", "lua",
    "markdown", "python", "r", "sql", "zig" },
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

-- nvim-tree --------------------------------------------------------------------------------------
require("nvim-tree").setup({
  -- Float, instead of using a drawer
  view = {
    float = { enable = true }
  },
  -- Show hidden files
  filters = {
    dotfiles = false,
  },
  -- Show gitignored files
  git = {
    enable = true,
    ignore = false
  },
})

-- lualine ----------------------------------------------------------------------------------------
require("lualine").setup({
  options = {
    globalstatus = true,
    icons_enabled = true,
    theme = "auto",
    -- component_separators = { left = "", right = "" },
    -- section_separators = { left = "", right = "" },
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

-- toggle-term ------------------------------------------------------------------------------------
require("toggleterm").setup({
  open_mapping = [[<c-\>]],
  direction = "float",
  float_opts = {
    border = "curved",
  }
})

-- keymaps ----------------------------------------------------------------------------------------
-- Prevent Neovim from announcing keymap changes

-- Set the leader key to space
vim.keymap.set("", "<Space>", "<Nop>", { silent = true })
vim.g.mapleader = " "

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { silent = true })

-- Buffer navigation
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { silent = true })
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { silent = true })

-- Manage buffers
vim.keymap.set("n", "<leader>c", "<cmd>bdelete!<CR>", { silent = true, desc = "Close buffer" })

-- Adjust indentation without leaving visual mode
vim.keymap.set("v", "<", "<gv", { silent = true })
vim.keymap.set("v", ">", ">gv", { silent = true })

-- Plugin: Comment
-- Toggle commenting
vim.keymap.set("n", "<leader>/", "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>",
  { silent = true, desc = "Toggle comment" })

vim.keymap.set("x", "<leader>/", '<ESC><CMD>lua require("Comment.api").toggle.linewise(vim.fn.visualmode())<CR>',
  { silent = true, desc = "Toggle comment" })

-- Plugin: nvim-tree
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true, desc = "Toggle file explorer" })

-- Plugin: lsp-zero
-- Alternative LSP keybindings, these don't override lsp-zero's keybindings, but I think it's
-- easiest to group these together
vim.keymap.set("n", "<leader>ld", "<CMD>lua vim.lsp.buf.definition()<CR>",
  { silent = true, desc = "Go to definition" })
vim.keymap.set("n", "<leader>lD", "<CMD>lua vim.lsp.buf.declaration()<CR>",
  { silent = true, desc = "Go to declaration" })
vim.keymap.set("n", "<leader>ll", "<CMD>lua vim.diagnostic.open_float()<CR>",
  { silent = true, desc = "Show diagnostic information" })
vim.keymap.set("n", "<leader>lo", "<CMD>lua vim.lsp.buf.type_definition()<CR>",
  { silent = true, desc = "Go to type definition" })
vim.keymap.set("n", "<leader>lr", "<CMD>lua vim.lsp.buf.rename()<CR>",
  { silent = true, desc = "Rename" })
vim.keymap.set("n", "<leader>lR", "<CMD>lua vim.lsp.buf.references()<CR>",
  { silent = true, desc = "List references" })
vim.keymap.set("n", "<leader>lf", ":LspZeroFormat<CR>", { silent = true, desc = "Reflow buffer" })

-- Plugin: nvim-r
-- Alternative nvim-r keybindings. These also don't override the default keybindings, and will
-- be always available, which can be wonky (i.e. if you try to call from another language).
vim.keymap.set("n", "<leader>rr", "<Plug>RStart", { silent = true, desc = "Start R" })
vim.keymap.set("n", "<leader>rq", "<Plug>RClose", { silent = true, desc = "Quit R" })
vim.keymap.set("n", "<leader>rs", "<Plug>RDSendLine", { silent = true, desc = "Send line to R" })
vim.keymap.set("v", "<leader>rs", "<Plug>RDSendSelection", { silent = true, desc = "Send selection to R" })
vim.keymap.set("n", "<leader>rp", "<Plug>RDSendParagraph", { silent = true, desc = "Send paragraph to R" })
vim.keymap.set("n", "<leader>rf", "<Plug>RDSendFunction", { silent = true, desc = "Send function to R" })
vim.keymap.set("n", "<leader>rh", "<Plug>RHelp", { silent = true, desc = "Show R Help" })
vim.keymap.set("n", "<leader>rQ", "<Plug>RQuartoRender", { silent = true, desc = "Render Quarto" })

-- Plugin: vim-dadbod and family
vim.keymap.set("n", "<leader>dd", ":DBUIToggle<CR>", { silent = true, desc = "Open Dadbod UI" })
vim.keymap.set("n", "<leader>ds", ":<Plug>DBUI_ExecuteQuery", { silent = true, desc = "Run SQL script" })
vim.keymap.set("v", "<leader>ds", ":<Plug>DBUI_ExecuteQuery", { silent = true, desc = "Run SQL selection" })
-- remove some of the defaults
vim.keymap.set("n", "<leader>S", "<Nop>", { silent = true })
vim.keymap.set("v", "<leader>S", "<Nop>", { silent = true })
vim.keymap.set("n", "<leader>E", "<Nop>", { silent = true })
vim.keymap.set("n", "<leader>W", "<Nop>", { silent = true })


-- which-key --------------------------------------------------------------------------------------
local wk = require("which-key")
wk.setup()
-- This doesn't add any keymaps, just labels groups
wk.register({
  ["<leader>"] = {
    -- Label keybinding sections
    l = {
      name = "+LSP"
    },
    r = {
      name = "+R"
    },
    d = {
      name = "+DB"
    },
  },
  -- These are the default lsp-zero keybindings, label them to be nice
  g = {
    d = { "LSP: Go to definition" },
    D = { "LSP: Go to declaration" },
    l = { "LSP: Show diagnoistic information" },
    o = { "LSP: Go to type definition" },
    r = { "LSP: List references" },
  },
  -- TODO: the same for nvim-r? It uses a local-leader, so that's a wrinkle.
})

-- Autocommands -----------------------------------------------------------------------------------
-- Easily exit help/man/etc panels
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "help", "man", "lspinfo", "quickfix" },
  callback = function()
    vim.cmd([[
      nnoremap <silent> <buffer> q :close<CR> 
      set nobuflisted 
    ]])
  end,
})
