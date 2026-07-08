vim.cmd("hi clear")
vim.g.colors_name = "brutal"

local hl = function(...) vim.api.nvim_set_hl(0, ...) end
local dark = vim.o.background == "dark"

local c = {
    bg        = dark and "NONE"    or "#FFFFFF",
    fg        = dark and "#FFFFFF" or "#000000",
    faint     = dark and "#AAAAAA" or "#999999",
    red       = "#FF0000",
    blue      = dark and "#99CCFF" or "#0000FF",
    green     = "#00DD00",
    orange    = "#FFAA00",
    selection = dark and "#4A6066" or "#9090FF",
    dim       = dark and "#111111" or "#EEEEEE",
}

-- Capture every non-configured group
-- for hlg, _ in pairs(vim.api.nvim_get_hl(0, {})) do
--     hl(hlg, { bg = c.red })
-- end

-- Surrounding Components
hl("Normal", { fg = c.fg })
hl("LineNr", { fg = c.blue })
hl("CursorLineNr", { fg = c.blue })
hl("CursorLine", { bg = c.selection })
hl("Visual", { bg = c.selection })
hl("Pmenu", { fg = c.fg, bg = c.dim })
hl("PmenuSel", { fg = c.dim, bg = c.fg })
hl("PmenuBorder", { bg = c.dim })
hl("StatusLine", { fg = c.fg })
hl("TabLine", { fg = c.fg, bg = c.bg })
hl("TabLineSel", { fg = c.fg, bg = c.bg, underline = true })
hl("Search", { fg = c.bg, bg = c.blue })
hl("MatchParen", { fg = c.red, bold = true })
hl("DiagnosticHint", { fg = c.green })
hl("DiagnosticError", { bg = c.red, fg = c.bg })
hl("DiagnosticError", { fg = c.red })
hl("DiagnosticWarn", { fg = c.orange })
hl("DiagnosticUnderlineWarn", { underline = true, sp = c.orange })
hl("DiagnosticInfo", { fg = c.blue })
hl("DiffAdd", { fg = c.green })
hl("DiffChange", { fg = c.blue })
hl("DiffDelete", { fg = c.red })
hl("MsgArea", { fg = c.fg })
hl("NonText", { fg = c.bg })

-- Type
hl("@type", { fg = c.fg })
hl("@type.builtin.rust", { fg = c.fg })

hl("@lsp.type.type", { fg = c.fg })
hl("@lsp.type.class", { fg = c.fg })
hl("@lsp.type.struct", { fg = c.fg })
hl("@lsp.type.enum", { fg = c.fg })
hl("@lsp.type.interface", { fg = c.fg })

-- Term
hl("@constructor", { fg = c.blue })
hl("@property", { fg = c.blue })
hl("@attribute", { fg = c.blue })
hl("@attribute.rust", { fg = c.red })
hl("@attribute.builtin.rust", { fg = c.red })
hl("@variable", { fg = c.blue })
hl("@variable.builtin", { fg = c.red })
hl("@constant", { fg = c.blue })
hl("@constant.builtin", { fg = c.blue })
hl("@function", { fg = c.blue })
hl("@function.builtin", { fg = c.blue })
hl("@module", { fg = c.blue })
hl("@module.builtin", { fg = c.blue })
hl("@namespace", { fg = c.blue })
hl("@tag", { fg = c.blue })
hl("@tag.attribute", { fg = c.blue, italic = true })

hl("@lsp.type.variable", { fg = c.blue })
hl("@lsp.type.property", { fg = c.blue })
hl("@lsp.type.function", { fg = c.blue })
hl("@lsp.type.method", { fg = c.blue })
hl("@lsp.type.namespace", { fg = c.blue })
hl("@lsp.type.parameter", { fg = c.blue })
hl("@lsp.type.enumMember", { fg = c.blue })

-- Keyword
hl("@keyword", { fg = c.red })
hl("@punctuation", { fg = c.red })
hl("@punctuation.special", { fg = c.red })
hl("@character.special.rust", { fg = c.red })
hl("@operator", { fg = c.red })
hl("@label", { fg = c.red })
hl("@tag.delimiter", { fg = c.red })

hl("@lsp.type.keyword", { fg = c.red })
hl("@lsp.type.operator", { fg = c.red })

-- Comment
hl("@comment", { fg = c.faint, italic = true })
hl("@comment.todo", { fg = c.bg, bg = c.green, bold = true })

hl("@lsp.type.comment", { fg = c.faint, italic = true })

-- Literal
hl("@string", { fg = c.green })
hl("@string.escape", { fg = c.green })
hl("@number", { fg = c.green })
hl("@character", { fg = c.green })
hl("@boolean", { fg = c.green })

hl("@lsp.type.string", { fg = c.green })
hl("@lsp.type.number", { fg = c.green })

-- Markup
hl("@markup.raw.markdown_inline",  { fg = c.blue })
hl("@markup.list.markdown", { fg = c.red })
hl("@markup.raw.block.markdown", { fg = c.red })
