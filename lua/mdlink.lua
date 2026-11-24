-- Follow markdown [text](target) links: #anchor, file.md#anchor, or a URL.
local M = {}

-- GitHub-style heading slug: lowercase, drop punctuation, spaces -> hyphens.
function M.slug(text)
  return (text:lower():gsub("[^%w%-_ ]", ""):gsub(" ", "-"))
end

-- Pure: the link target under 1-based byte column `col` of `line`, or nil.
function M.link_at(line, col)
  local init = 1
  while true do
    local s, e, target = line:find("%[.-%]%((.-)%)", init)
    if not s then return nil end
    if col >= s and col <= e then return target end
    init = e + 1
  end
end

-- Pure: parse a target into { url = ... } or { file = ..., anchor = ... } ("" when absent).
function M.parse(target)
  if target:match("^%a+://") then return { url = target } end
  local file, anchor = target:match("^([^#]*)#?(.*)$")
  return { file = file, anchor = vim.uri_decode and vim.uri_decode(anchor) or anchor }
end

-- Pure: 1-based line number of the heading whose slug is `anchor` in `lines`, or nil.
-- Duplicate headings get -1, -2, ... like GitHub.
function M.find_heading(lines, anchor)
  local seen = {}
  for lnum, line in ipairs(lines) do
    local heading = line:match("^#+%s+(.-)%s*#*$")
    if heading then
      local base = M.slug(heading)
      local s = seen[base] and (base .. "-" .. seen[base]) or base
      seen[base] = (seen[base] or 0) + 1
      if s == anchor then return lnum end
    end
  end
end

-- Effectful: follow the link under the cursor; returns false when not on a link.
function M.follow()
  local target = M.link_at(vim.api.nvim_get_current_line(), vim.fn.col("."))
  if not target then return false end
  local link = M.parse(target)
  if link.url then vim.ui.open(link.url) return true end
  vim.cmd("normal! m'")
  if link.file ~= "" then
    vim.cmd.edit(vim.fn.fnameescape(vim.fn.expand("%:p:h") .. "/" .. link.file))
  end
  if link.anchor ~= "" then
    local lnum = M.find_heading(vim.api.nvim_buf_get_lines(0, 0, -1, false), link.anchor)
    if lnum then
      vim.api.nvim_win_set_cursor(0, { lnum, 0 })
    else
      vim.notify("No heading for #" .. link.anchor, vim.log.levels.WARN)
    end
  end
  return true
end

return M
