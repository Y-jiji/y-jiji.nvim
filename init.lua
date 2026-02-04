vim.cmd("colorscheme brutal")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = { 
     {
       "hrsh7th/nvim-cmp", 
       dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "L3MON4D3/LuaSnip" }, 
       opts = { sources = { { name = "nvim_lsp" }, { name = "buffer" } } }  
     },
     {
        "HiPhish/rainbow-delimiters.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
	event = "BufReadPost",
     },
     {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
	opts = { ensure_installed = "all", highlight = { enable = true }, sync_install = false },
        build = ":TSUpdate"
     },
     {
        "sphamba/smear-cursor.nvim",
	opts = { smear_between_buffers = true, smear_between_neighbor_lines = false, smear_insert_mode = true }
     }
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "brutal" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

-- Setup LSP Capabilities
local lspcap = require("cmp_nvim_lsp").default_capabilities()
vim.lsp.config("rust_analyzer", {
  cmd = { "rust-analyzer" },
  root_markers = { "Cargo.toml" },
  filetypes = { "rust" },
  capabilities = caps
})
vim.lsp.enable("rust_analyzer")
vim.lsp.config("texlab", {
  cmd = { "texlab" },
  filetypes = { "tex", "plaintex", "bibtex" },
  root_markers = { "latexmkrc" },
  settings = { texlab = { build = { onSave = true } } }, 
  capabilities = caps,
})
vim.lsp.enable("texlab")
vim.lsp.config("clangd", {
  cmd = { "clangd" },
  filetypes = { "c", "cpp" },
  root_markers = { "compile_commands.json" },
  capabilities = caps,
})
vim.lsp.enable("clangd")
vim.diagnostic.config({ underline = true, virtual_text = true, signs = false })
vim.opt.signcolumn = "no"
vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = true })
vim.keymap.set("n", "<F8>", function()
  vim.diagnostic.setqflist({ open = true })
end, { desc = "Populate quickfix with all diagnostics and open" })
vim.keymap.set("n", "<F12>", vim.lsp.buf.definition, { desc = "Goto definition", buffer = true })

-- Setup Tree Sitter
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args) pcall(vim.treesitter.start, args.buf) end,
})

-- Setup Theme
vim.g.rainbow_delimiters = {
  strategy = { [""] = require("rainbow-delimiters").strategy["global"] },
  query = { [""] = "rainbow-delimiters" },
  highlight = { "RainbowRed", "RainbowBlue" }
}

-- Setup Cursor Navigation
vim.keymap.set("n", "<down>", "gj") 
vim.keymap.set("n", "<up>", "gk") 
vim.keymap.set("i", "<Down>", "<C-o>gj", { noremap = true, silent = true })
vim.keymap.set("i", "<Up>", "<C-o>gk", { noremap = true, silent = true })
