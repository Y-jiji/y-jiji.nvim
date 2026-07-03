-- =============================================================================
-- Neovim Setup Overview
-- (Prolog)  bootstrap lazy.nvim, define list of plugins and list of lsps, setup default hooks
-- (Project) run .nvim.lua as a function; append to plugin list and lsp list, configure options, setup project hooks
-- (Epilog)  run lazy.setup, configure lsps
-- =============================================================================

DEBUG = false

function vim.debug(msg)
    if DEBUG then vim.print(msg) end
end

-- =============================================================================
-- (Prolog::Plugin)  bootstrap lazy.nvim, define list of plugins
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

-- variable for collecting plugin
local spec = {}
local function plugin(plugin_)
    table.insert(spec, plugin_)
end

-- =============================================================================
-- (Prolog::LSP) define list of lsps, setup default hooks
-- =============================================================================

-- variable for collecting lsp
local lsps = {}
local function lsp(name_, spec_)
    lsps[name_] = spec_
end

-- severity_sort places the most severe diagnostic's virtual text first on each
-- line, so the dominant (red) message reads at the top.
vim.diagnostic.config({
    underline = true,     -- squiggly underline under the offending text
    virtual_text = true,  -- inline message to the right of the line
    signs = false,        -- no gutter markers in the sign column
    severity_sort = true, -- most severe diagnostic's text renders first per line
})

-- By default do not use semantic colors
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end
        vim.debug("highlight(semantics): lsp semantics syntax off")
        client.server_capabilities.semanticTokensProvider = nil
    end,
})

-- Hotkeys: setup default hot keys
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(_args)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
        vim.keymap.set("n", "<F12>", vim.lsp.buf.definition, { desc = "Goto definition" })
        vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, { desc = "Rename" })
        vim.keymap.set("n", "<F8>", function() vim.diagnostic.setqflist({ open = true }) end,
            { desc = "Populate quickfix with all diagnostics and open" })
        vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Actions" })
        vim.keymap.set("n", "<leader>cf", function() vim.lsp.buf.format() end, { desc = "Format code" })
    end,
})

-- =============================================================================
-- (Prolog::Statusline) remove most editor widgets
-- =============================================================================

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

-- =============================================================================
-- (Prolog::Navi) define navigation hot keys
-- =============================================================================

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
-- (Prolog::VimState) configure vim state persisting folders
-- =============================================================================

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

-- =============================================================================
-- (Prolog::Default) define hot keys and indentation
-- =============================================================================

-- Default indent (soft default; ftplugins/.editorconfig may override).
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.autoindent = false

-- Leader Key
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- =============================================================================
-- (Prolog::Yazi) Setup file navigation using yazi
-- =============================================================================

vim.keymap.set({ "n", "v" }, "<leader>-",
    function() require("yazi").open() end,
    { desc = "Open yazi in current window" })
require("yazi").setup()

-- =============================================================================
-- (Prolog::Syntax) Treesitter for all projects
-- =============================================================================

vim.cmd("syntax off")
vim.cmd("colorscheme brutal")

-- Tree sitter installation
plugin {
    "romus204/tree-sitter-manager.nvim",
    dependencies = {}, -- tree-sitter CLI must be installed system-wide
    config = function()
        require("tree-sitter-manager").setup()
    end,
}

-- Start treesitter
vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
        vim.debug(("highlight(syntax): treesitter syntax on (original: %s)"):format(lang))
        local status, _ = pcall(vim.treesitter.start, args.buf, lang)
        if not status then
            vim.print(("No treesitter for %s"):format(lang))
        end
    end
})

-- =============================================================================
-- (Project) load per-project .nvim.lua; run it as function
-- =============================================================================

local nvimlua, err = loadfile(vim.fn.getcwd() .. "/.nvim.lua")
if nvimlua then
    local ok, err = pcall(nvimlua, plugin, lsp)
    if not ok then
        vim.debug(("project(execute): %s"):format(err))
    end
else
    vim.debug(("project(load): %s"):format(err))
end

-- =============================================================================
-- (Epilog) setup lazy + lsps
-- =============================================================================

-- Every project's .nvim.lua plugins are appended to the same `spec` table, so
-- without a per-project lockfile they'd all lock into this repo's
-- lazy-lock.json: opening an unrelated project and updating its plugins
-- would dirty this repo's lock with versions that have nothing to do with
-- it. When a project provides its own .nvim.lua, keep its plugin pins
-- alongside it instead; otherwise fall back to this config's own lockfile.
local lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json"
if nvimlua then
    lockfile = vim.fn.getcwd() .. "/.nvim-lazy-lock.json"
end

require("lazy").setup({
    spec = spec,
    lockfile = lockfile,
    checker = { enabled = true },
})

for name, spec in pairs(lsps) do
    vim.lsp.config(name, spec)
    vim.lsp.enable(name)
end
