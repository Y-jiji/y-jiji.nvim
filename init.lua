vim.cmd("colorscheme brutal")
vim.cmd("syntax off")

vim.opt.cmdheight = 0
vim.opt.showmode = false

local _modes = { n="N", i="I", v="V", V="VL", ["\22"]="VB", R="R", c="C", t="T", s="S" }
_G.statusline_mode = function() return _modes[vim.fn.mode()] or vim.fn.mode() end
vim.opt.statusline = " %{v:lua.statusline_mode()} | %f %m%r%= %y | %l:%c "

vim.api.nvim_create_autocmd("CmdlineEnter", { callback = function() vim.opt.laststatus = 0 end })
vim.api.nvim_create_autocmd("CmdlineLeave", { callback = function() vim.opt.laststatus = 3 end })

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out,                            "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		{
			"nvim-treesitter/nvim-treesitter",
			branch = "main",
			lazy = false,
			build = ":TSUpdate",
		},
		{
			"sphamba/smear-cursor.nvim",
			opts = {
				smear_between_buffers = true,
				smear_between_neighbor_lines = false,
				smear_insert_mode = true,
			},
		},
		{
			"nvim-telescope/telescope.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
			keys = {
				{ "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Live grep" },
				{ "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Buffers" },
				{ "<leader>fh", "<cmd>Telescope help_tags<cr>",  desc = "Help tags" },
			},
		},
		{
			"chomosuke/typst-preview.nvim",
			ft = "typst",
			build = function() require("typst-preview").update() end,
			opts = {},
		},
		{
			"Julian/lean.nvim",
			event = { "BufReadPre *.lean", "BufNewFile *.lean" },
			dependencies = { "nvim-lua/plenary.nvim" },
			opts = { mappings = true },
		},
	},
	-- auto update checking
	checker = { enabled = true },
})

-- LSP servers
vim.lsp.config("rust_analyzer", {
	cmd = { "rust-analyzer" },
	root_markers = { "Cargo.toml" },
	filetypes = { "rust" },
})
vim.lsp.enable("rust_analyzer")
vim.lsp.config("texlab", {
	cmd = { "texlab" },
	filetypes = { "tex", "plaintex", "bibtex" },
	root_markers = { "latexmkrc" },
	settings = { texlab = { build = { onSave = true } } },
})
vim.lsp.enable("texlab")
vim.lsp.config("clangd", {
	cmd = { "clangd" },
	filetypes = { "c", "cpp", "cuda" },
	root_markers = { "compile_commands.json", ".clangd" },
})
vim.lsp.enable("clangd")
vim.lsp.config("tinymist", {
	cmd = { "tinymist" },
	filetypes = { "typst" },
	root_markers = { "typst.toml", ".git" },
})
vim.lsp.enable("tinymist")
vim.lsp.config("lua_ls", {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
})
vim.lsp.enable("lua_ls")
vim.diagnostic.config({ underline = true, virtual_text = true, signs = false })
vim.api.nvim_create_autocmd("FileType", {
	callback = function(args) pcall(vim.treesitter.start, args.buf) end,
})
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client then return end
		if client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
		end
		local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
		if lang and pcall(vim.treesitter.get_parser, args.buf, lang) then
			-- Treesitter owns this buffer; drop the server's token coloring.
			client.server_capabilities.semanticTokensProvider = nil
		end
	end,
})

-- Default indent for all languages (soft default; ftplugins/.editorconfig may override)
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.autoindent = true

-- Setup Cursor Navigation
vim.keymap.set("n", "<down>", "gj")
vim.keymap.set("n", "<up>", "gk")
vim.keymap.set("i", "<Down>", "<C-o>gj", { noremap = true, silent = true })
vim.keymap.set("i", "<Up>", "<C-o>gk", { noremap = true, silent = true })

-- Window Navigation: Ctrl+Arrow in any mode
for key, dir in pairs({ Left = "h", Down = "j", Up = "k", Right = "l" }) do
	vim.keymap.set({ "n", "v", "i", "t" }, "<C-" .. key .. ">", "<Cmd>wincmd " .. dir .. "<CR>",
		{ desc = "Window " .. key:lower() })
end
vim.keymap.set({ "n", "v", "i" }, "<leader>-", 
    function() require("yazi").open() end, 
    { desc = "Open yazi in current window" }
)
require("yazi").setup()

vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
vim.keymap.set("n", "<F12>", vim.lsp.buf.definition, { desc = "Goto definition" })
vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, { desc = "Rename" })
vim.keymap.set("n", "<F8>", function() vim.diagnostic.setqflist({ open = true }) end,
	{ desc = "Populate quickfix with all diagnostics and open" })
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Actions" })
vim.keymap.set("n", "<leader>cf", function() vim.lsp.buf.format() end, { desc = "Format code" })

-- Persistent undo, swap, and backup in centralized dirs
-- The // suffix encodes full file paths to ensure uniqueness
local statedir = vim.fn.stdpath("state")
for _, sub in ipairs({ "undo", "swap", "backup" }) do
	vim.fn.mkdir(statedir .. "/" .. sub, "p")
end
vim.opt.undofile = true
vim.opt.undodir = statedir .. "/undo//"
vim.opt.directory = statedir .. "/swap//"
vim.opt.backupdir = statedir .. "/backup//"

-- Project-local config files (.nvimrc / .exrc)
vim.opt.exrc = true
