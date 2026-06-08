vim.cmd("hi clear")
vim.g.colors_name = "brutal"

local hl = vim.api.nvim_set_hl
local dark = vim.o.background == "dark"

local c = {
    bg        = dark and "#000000" or "#FFFFFF",
    fg        = dark and "#FFFFFF" or "#000000",
    faint     = dark and "#AAAAAA" or "#999999",
    red       = "#FF0000",
    blue      = dark and "#99CCFF" or "#0000FF",
    green     = "#00DD00",
    orange    = "#FFAA00",
    selection = dark and "#4A6066" or "#9090FF",
    dim       = dark and "#111111" or "#EEEEEE",
}

hl(0, "Normal", { fg = c.fg })
hl(0, "LineNr", { fg = c.blue })
hl(0, "CursorLineNr", { fg = c.blue })
hl(0, "CursorLine", { bg = c.selection })
hl(0, "Visual", { bg = c.selection })
hl(0, "Pmenu", { fg = c.fg, bg = c.dim })
hl(0, "PmenuSel", { fg = c.dim, bg = c.fg })
hl(0, "PmenuBorder", { bg = c.dim })
hl(0, "StatusLine", { fg = c.fg, bg = c.bg })
hl(0, "TabLine", { fg = c.fg, bg = c.bg })
hl(0, "TabLineSel", { fg = c.fg, bg = c.bg, underline = true })
hl(0, "Search", { fg = c.bg, bg = c.blue })
hl(0, "MatchParen", { fg = c.red, bold = true })
hl(0, "DiagnosticHint", { fg = c.green })
hl(0, "DiagnosticError", { bg = c.red, fg = c.bg })
hl(0, "DiagnosticError", { fg = c.red })
hl(0, "DiagnosticWarn", { fg = c.orange })
hl(0, "DiagnosticInfo", { fg = c.blue })
hl(0, "DiffAdd", { fg = c.green })
hl(0, "DiffChange", { fg = c.blue })
hl(0, "DiffDelete", { fg = c.red })

hl(0, "@type", { fg = c.fg })
hl(0, "@type.builtin.rust", { fg = c.fg })

hl(0, "@constructor", { fg = c.blue })
hl(0, "@property", { fg = c.blue })
hl(0, "@attribute", { fg = c.blue })
hl(0, "@attribute.rust", { fg = c.red })
hl(0, "@attribute.builtin.rust", { fg = c.red })
hl(0, "@variable", { fg = c.blue })
hl(0, "@variable.builtin", { fg = c.red })
hl(0, "@constant", { fg = c.blue })
hl(0, "@constant.builtin", { fg = c.blue })
hl(0, "@function", { fg = c.blue })
hl(0, "@module", { fg = c.blue })
hl(0, "@namespace", { fg = c.blue })
hl(0, "@tag", { fg = c.blue })
hl(0, "@tag.attribute", { fg = c.blue, italic = true })

hl(0, "@keyword", { fg = c.red })
hl(0, "@punctuation", { fg = c.red })
hl(0, "@punctuation.special", { fg = c.red })
hl(0, "@character.spectial.rust", { fg = c.red })
hl(0, "@operator", { fg = c.red })
hl(0, "@label", { fg = c.red })
hl(0, "@tag.delimiter", { fg = c.red })
hl(0, "@comment", { fg = c.faint, italic = true })
hl(0, "@comment.todo", { fg = c.bg, bg = c.green, bold = true })

hl(0, "@string", { fg = c.green })
hl(0, "@number", { fg = c.green })
hl(0, "@character", { fg = c.green })
hl(0, "@boolean", { fg = c.green })
