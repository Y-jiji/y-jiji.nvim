-- =============================================================================
-- Debug mode tool
-- =============================================================================

DEBUG = false

function vim.debug(msg)
    if DEBUG then
        vim.print(msg)
    end
end

-- =============================================================================
-- Lazy.nvim bootstrap and plugin specs
-- =============================================================================

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

-- Leader and netrw must be set before plugins resolve <leader>... keymaps.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("lazy").setup({
    spec = {
        {
            "Y-jiji/tinymist-kitty",
            ft = "typst",
            opts = {
                dpi = 96,
                cell_px = { w = 19, h = 42 },
                emit_debounce_ms = 0,
            },
            build = "cargo install --path crates/typst-term-preview --locked",
        },
        {
            "romus204/tree-sitter-manager.nvim",
            dependencies = {}, -- tree-sitter CLI must be installed system-wide
            config = function()
                require("tree-sitter-manager").setup()
            end,
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
            "folke/lazydev.nvim",
            ft = "lua",
            opts = {
                library = {
                    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                },
            },
        },
        {
            "Julian/lean.nvim",
            lazy = false,
            dependencies = { "nvim-lua/plenary.nvim" },
            opts = {
                mappings = true,
                signs = { enabled = false },
                goal_markers = { accomplished = "", },
            },
        },
    },
    -- auto update checking
    checker = { enabled = true },
})

-- =============================================================================
-- State and per-project config
-- =============================================================================

-- Default indent (soft default; ftplugins/.editorconfig may override).
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.autoindent = false

-- Persistent undo, swap, and backup in centralized dirs.
-- The // suffix encodes full file paths to ensure uniqueness.
local statedir = vim.fn.stdpath("state")
for _, sub in ipairs({ "undo", "swap", "backup" }) do
    vim.fn.mkdir(statedir .. "/" .. sub, "p")
end
vim.opt.undofile = true
vim.opt.undodir = statedir .. "/undo//"
vim.opt.directory = statedir .. "/swap//"
vim.opt.backupdir = statedir .. "/backup//"

-- Project-local config files (.nvimrc / .exrc).
vim.opt.exrc = true

-- =============================================================================
-- Theme, statusline, and file navigation
-- =============================================================================

vim.cmd("colorscheme brutal")

vim.opt.cmdheight = 0
vim.opt.laststatus = 3
vim.opt.showmode = false
vim.opt.showcmd = false
vim.opt.ruler = false
vim.opt.showtabline = 0 -- no tab bar; tabs are shown as dots in the statusline

local _modes = { n = "N", i = "I", v = "V", V = "VL", ["\22"] = "VB", R = "R", c = "C", t = "T", s = "S" }
_G.statusline_mode = function() return _modes[vim.fn.mode()] or vim.fn.mode() end

-- One dot per tabpage, current filled; shown only when more than one tab exists.
_G.statusline_tabs = function()
    local n = vim.fn.tabpagenr("$")
    if n < 2 then return "" end
    local cur = vim.fn.tabpagenr()
    local dots = {}
    for i = 1, n do dots[i] = (i == cur) and "●" or "○" end
    return table.concat(dots) .. " | "
end

vim.opt.statusline = " %{v:lua.statusline_mode()} | %f %m%r%= %y | %{v:lua.statusline_tabs()}%l:%c "

-- Cursor navigation: arrow keys move by display line.
vim.keymap.set("n", "<down>", "gj")
vim.keymap.set("n", "<up>", "gk")
vim.keymap.set("i", "<Down>", "<C-o>gj", { noremap = true, silent = true })
vim.keymap.set("i", "<Up>", "<C-o>gk", { noremap = true, silent = true })

-- Window navigation: Ctrl+Arrow in any mode.
for key, dir in pairs({ Left = "h", Down = "j", Up = "k", Right = "l" }) do
    vim.keymap.set({ "n", "v", "i", "t" }, "<C-" .. key .. ">", "<Cmd>wincmd " .. dir .. "<CR>",
        { desc = "Window " .. key:lower() })
end

-- =============================================================================
-- Highlighting (tree-sitter, syntax, diagnostics, semantic tokens)
-- =============================================================================

vim.cmd("syntax off")

-- severity_sort places the most severe diagnostic's virtual text first on each
-- line, so the dominant (red) message reads at the top.
vim.diagnostic.config({
    underline = true,     -- squiggly underline under the offending text
    virtual_text = true,  -- inline message to the right of the line
    signs = false,        -- no gutter markers in the sign column
    severity_sort = true, -- most severe diagnostic's text renders first per line
})

-- Force semantic tokens for leanls: the server responds to the request but
-- does not advertise the capability in a way Neovim parses.
-- Lean core only emits the first four token types; "leanSorryLike" is a Lean
-- extension that must stay at index 23 (the server sends positional indices, so
-- the unused middle entries cannot be dropped without shifting it). Lean core
-- emits no modifiers, so the modifier list is omitted.
local lean_sem_legend = {
    tokenTypes = {
        "keyword", "variable", "property", "function",
        "_", "_", "_", "_", "_", "_", "_", "_", "_", "_",
        "_", "_", "_", "_", "_", "_", "_", "_", "_",
        "_",
    },
    tokenModifiers = {},
}

-- The tree-sitter language for a buffer, or nil if no parser is available.
local function buf_ts_lang(buf)
    local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
    if lang and pcall(vim.treesitter.get_parser, buf, lang) then return lang end
end

-- Start treesitter
vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        local lang = buf_ts_lang(args.buf)
        if lang then
            vim.debug(("highlight(syntax): treesitter syntax on (original: %s)"):format(lang))
            vim.treesitter.start(args.buf, lang)
        end
    end
})

-- Disable regex-based nvim sytnax, use tree-sitter index
vim.api.nvim_create_autocmd("Syntax", {
    callback = function(args)
        if vim.bo[args.buf].syntax ~= "" then
            vim.debug(("highlight(syntax): legacy syntax off (original: %s)"):format(vim.bo[args.buf].syntax))
            vim.bo[args.buf].syntax = ""
        end
    end,
})

-- Use treesitter only if available
-- Exception: leanls don't have reliable treesitter (truely dependent on semantics)
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end
        if client.name == "leanls" then
            vim.debug("highlight(semantics/lean): lean syntax on")
            client.server_capabilities.semanticTokensProvider = {
                full = true, range = true, legend = lean_sem_legend,
            }
        elseif buf_ts_lang(args.buf) then
            vim.debug("highlight(semantics): lsp semantics syntax off")
            client.server_capabilities.semanticTokensProvider = nil
        end
    end,
})

-- =============================================================================
-- LSP servers and keymaps
-- =============================================================================

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
vim.lsp.config("lua", {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
})
vim.lsp.enable("lua")

vim.opt.completeopt = { "noselect", "noinsert", "menu", "menuone" }

-- Completion: enable autotrigger for any client that supports it.
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        end
    end,
})

vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
vim.keymap.set("n", "<F12>", vim.lsp.buf.definition, { desc = "Goto definition" })
vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, { desc = "Rename" })
vim.keymap.set("n", "<F8>", function() vim.diagnostic.setqflist({ open = true }) end,
    { desc = "Populate quickfix with all diagnostics and open" })
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Actions" })
vim.keymap.set("n", "<leader>cf", function() vim.lsp.buf.format() end, { desc = "Format code" })

-- =============================================================================
-- Kitty Graphics Modules
-- =============================================================================

-- Yazi as the file picker / directory opener.
vim.keymap.set({ "n", "v" }, "<leader>-",
    function() require("yazi").open() end,
    { desc = "Open yazi in current window" })
require("yazi").setup()
