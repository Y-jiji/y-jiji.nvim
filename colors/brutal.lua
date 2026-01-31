vim.cmd("hi clear")
vim.g.colors_name = "brutal"

local hl = vim.api.nvim_set_hl
local dark = vim.o.background == "dark"

local c = {
  bg      = dark and "#000000" or "#FFFFFF",
  fg      = dark and "#FFFFFF" or "#000000",
  comment = dark and "#AAAAAA" or "#999999",
  keyword = "#FF0000",
  const   = "#00DD00",
  sel     = dark and "#4A6066" or "#8080FF",
  var     = dark and "#99CCFF" or "#0000FF",
  dim     = dark and "#222222" or "#DDDDDD",
}

hl(0, "Normal", { fg = c.fg, bg = c.bg })
hl(0, "Comment", { fg = c.comment, italic = true })
hl(0, "Constant", { fg = c.const })
hl(0, "String", { fg = c.const })
hl(0, "Character", { fg = c.const })
hl(0, "Number", { fg = c.const })
hl(0, "Boolean", { fg = c.const })
hl(0, "Float", { fg = c.const })
hl(0, "Identifier", { fg = c.var })
hl(0, "Function", { fg = c.var })
hl(0, "Statement", { fg = c.keyword })
hl(0, "Conditional", { fg = c.keyword })
hl(0, "Repeat", { fg = c.keyword })
hl(0, "Label", { fg = c.keyword })
hl(0, "Operator", { fg = c.keyword })
hl(0, "Keyword", { fg = c.keyword })
hl(0, "Exception", { fg = c.keyword })
hl(0, "PreProc", { fg = c.keyword })
hl(0, "Include", { fg = c.keyword })
hl(0, "Define", { fg = c.keyword })
hl(0, "Macro", { fg = c.keyword })
hl(0, "Type", { fg = c.fg })
hl(0, "StorageClass", { fg = c.keyword })
hl(0, "Structure", { fg = c.keyword })
hl(0, "Typedef", { fg = c.fg })
hl(0, "Special", { fg = c.keyword })
hl(0, "Delimiter", { fg = c.keyword })
hl(0, "SpecialComment", { fg = c.comment, italic = true })
hl(0, "Error", { fg = "#DD0000", underline = true })
hl(0, "Todo", { fg = c.bg, bg = c.const, bold = true })
hl(0, "LineNr", { fg = dark and c.var or "#777777" })
hl(0, "CursorLineNr", { fg = c.var })
hl(0, "CursorLine", { bg = c.dim })
hl(0, "Visual", { bg = c.sel })
hl(0, "Pmenu", { fg = c.fg, bg = c.dim })
hl(0, "PmenuSel", { fg = c.bg, bg = c.var })
hl(0, "StatusLine", { fg = c.fg, bg = c.bg })
hl(0, "TabLine", { fg = c.fg, bg = c.bg })
hl(0, "TabLineSel", { fg = c.fg, bg = c.bg, underline = true })
hl(0, "Search", { fg = c.bg, bg = c.var })
hl(0, "MatchParen", { fg = c.keyword, bold = true })
hl(0, "DiagnosticError", { fg = "#FF0000" })
hl(0, "DiagnosticWarn", { fg = "#FFAA00" })
hl(0, "DiagnosticInfo", { fg = c.var })
hl(0, "DiagnosticHint", { fg = c.const })
hl(0, "DiffAdd", { fg = c.const })
hl(0, "DiffChange", { fg = c.var })
hl(0, "DiffDelete", { fg = c.keyword })
hl(0, "@variable", { fg = c.var })
hl(0, "@function", { fg = c.var })
hl(0, "@keyword", { fg = c.keyword })
hl(0, "@string", { fg = c.const })
hl(0, "@number", { fg = c.const })
hl(0, "@constant", { fg = c.const })
hl(0, "@type", { fg = c.fg })
hl(0, "@comment", { fg = c.comment, italic = true })
hl(0, "@punctuation", { fg = c.keyword })
hl(0, "@tag", { fg = c.var })
hl(0, "@tag.attribute", { fg = c.keyword, italic = true })
hl(0, "@tag.delimiter", { fg = c.keyword })
