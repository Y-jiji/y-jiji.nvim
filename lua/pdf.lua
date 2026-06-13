-- Render PDFs inline via the Kitty graphics protocol (Unicode placeholders).
-- Requires: pdftoppm, pdfinfo (poppler)

local M = {}

local PH = "\xF4\x8E\xBB\xAE" -- U+10EEEE

-- Row diacritics (combining class 230) from the Kitty Unicode-placeholder spec.
local DIACRITICS = {
  "\xCC\x85", "\xCC\x8D", "\xCC\x8E", "\xCC\x90", "\xCC\x92", "\xCC\xBD", "\xCC\xBE", "\xCC\xBF",
  "\xCD\x86", "\xCD\x8A", "\xCD\x8B", "\xCD\x8C", "\xCD\x90", "\xCD\x91", "\xCD\x92", "\xCD\x97",
  "\xCD\x9B", "\xCD\xA3", "\xCD\xA4", "\xCD\xA5", "\xCD\xA6", "\xCD\xA7", "\xCD\xA8", "\xCD\xA9",
  "\xCD\xAA", "\xCD\xAB", "\xCD\xAC", "\xCD\xAD", "\xCD\xAE", "\xCD\xAF", "\xD2\x83", "\xD2\x84",
  "\xD2\x85", "\xD2\x86", "\xD2\x87", "\xD6\x92", "\xD6\x93", "\xD6\x94", "\xD6\x95", "\xD6\x97",
  "\xD6\x98", "\xD6\x99", "\xD6\x9C", "\xD6\x9D", "\xD6\x9E", "\xD6\x9F", "\xD6\xA0", "\xD6\xA1",
  "\xD6\xA8", "\xD6\xA9", "\xD6\xAB", "\xD6\xAC", "\xD6\xAF", "\xD7\x84", "\xD8\x90", "\xD8\x91",
  "\xD8\x92", "\xD8\x93", "\xD8\x94", "\xD8\x95", "\xD8\x96", "\xD8\x97", "\xD9\x97", "\xD9\x98",
  "\xD9\x99", "\xD9\x9A", "\xD9\x9B", "\xD9\x9D", "\xD9\x9E", "\xDB\x96", "\xDB\x97", "\xDB\x98",
  "\xDB\x99", "\xDB\x9A", "\xDB\x9B", "\xDB\x9C", "\xDB\x9F", "\xDB\xA0", "\xDB\xA1", "\xDB\xA2",
  "\xDB\xA4", "\xDB\xA7", "\xDB\xA8", "\xDB\xAB", "\xDB\xAC", "\xDC\xB0", "\xDC\xB2", "\xDC\xB3",
  "\xDC\xB5", "\xDC\xB6", "\xDC\xBA", "\xDC\xBD", "\xDC\xBF", "\xDD\x80", "\xDD\x81", "\xDD\x83",
  "\xDD\x85", "\xDD\x87", "\xDD\x89", "\xDD\x8A", "\xDF\xAB", "\xDF\xAC", "\xDF\xAD", "\xDF\xAE",
  "\xDF\xAF", "\xDF\xB0", "\xDF\xB1", "\xDF\xB3", "\xE0\xA0\x96", "\xE0\xA0\x97", "\xE0\xA0\x98", "\xE0\xA0\x99",
  "\xE0\xA0\x9B", "\xE0\xA0\x9C", "\xE0\xA0\x9D", "\xE0\xA0\x9E", "\xE0\xA0\x9F", "\xE0\xA0\xA0", "\xE0\xA0\xA1", "\xE0\xA0\xA2",
  "\xE0\xA0\xA3", "\xE0\xA0\xA5", "\xE0\xA0\xA6", "\xE0\xA0\xA7", "\xE0\xA0\xA9", "\xE0\xA0\xAA", "\xE0\xA0\xAB", "\xE0\xA0\xAC",
  "\xE0\xA0\xAD", "\xE0\xA5\x91", "\xE0\xA5\x93", "\xE0\xA5\x94", "\xE0\xBE\x82", "\xE0\xBE\x83", "\xE0\xBE\x86", "\xE0\xBE\x87",
  "\xE1\x8D\x9D", "\xE1\x8D\x9E", "\xE1\x8D\x9F", "\xE1\x9F\x9D", "\xE1\xA4\xBA", "\xE1\xA8\x97", "\xE1\xA9\xB5", "\xE1\xA9\xB6",
  "\xE1\xA9\xB7", "\xE1\xA9\xB8", "\xE1\xA9\xB9", "\xE1\xA9\xBA", "\xE1\xA9\xBB", "\xE1\xA9\xBC", "\xE1\xAD\xAB", "\xE1\xAD\xAD",
  "\xE1\xAD\xAE", "\xE1\xAD\xAF", "\xE1\xAD\xB0", "\xE1\xAD\xB1", "\xE1\xAD\xB2", "\xE1\xAD\xB3", "\xE1\xB3\x90", "\xE1\xB3\x91",
  "\xE1\xB3\x92", "\xE1\xB3\x9A", "\xE1\xB3\x9B", "\xE1\xB3\xA0", "\xE1\xB7\x80", "\xE1\xB7\x81", "\xE1\xB7\x83", "\xE1\xB7\x84",
  "\xE1\xB7\x85", "\xE1\xB7\x86", "\xE1\xB7\x87", "\xE1\xB7\x88", "\xE1\xB7\x89", "\xE1\xB7\x8B", "\xE1\xB7\x8C", "\xE1\xB7\x91",
  "\xE1\xB7\x92", "\xE1\xB7\x93", "\xE1\xB7\x94", "\xE1\xB7\x95", "\xE1\xB7\x96", "\xE1\xB7\x97", "\xE1\xB7\x98", "\xE1\xB7\x99",
  "\xE1\xB7\x9A", "\xE1\xB7\x9B", "\xE1\xB7\x9C", "\xE1\xB7\x9D", "\xE1\xB7\x9E", "\xE1\xB7\x9F", "\xE1\xB7\xA0", "\xE1\xB7\xA1",
  "\xE1\xB7\xA2", "\xE1\xB7\xA3", "\xE1\xB7\xA4", "\xE1\xB7\xA5", "\xE1\xB7\xA6", "\xE1\xB7\xBE", "\xE2\x83\x90", "\xE2\x83\x91",
  "\xE2\x83\x94", "\xE2\x83\x95", "\xE2\x83\x96", "\xE2\x83\x97", "\xE2\x83\x9B", "\xE2\x83\x9C", "\xE2\x83\xA1", "\xE2\x83\xA7",
  "\xE2\x83\xA9", "\xE2\x83\xB0", "\xE2\xB3\xAF", "\xE2\xB3\xB0", "\xE2\xB3\xB1", "\xE2\xB7\xA0", "\xE2\xB7\xA1", "\xE2\xB7\xA2",
  "\xE2\xB7\xA3", "\xE2\xB7\xA4", "\xE2\xB7\xA5", "\xE2\xB7\xA6", "\xE2\xB7\xA7", "\xE2\xB7\xA8", "\xE2\xB7\xA9", "\xE2\xB7\xAA",
  "\xE2\xB7\xAB", "\xE2\xB7\xAC", "\xE2\xB7\xAD", "\xE2\xB7\xAE", "\xE2\xB7\xAF", "\xE2\xB7\xB0", "\xE2\xB7\xB1", "\xE2\xB7\xB2",
  "\xE2\xB7\xB3", "\xE2\xB7\xB4", "\xE2\xB7\xB5", "\xE2\xB7\xB6", "\xE2\xB7\xB7", "\xE2\xB7\xB8", "\xE2\xB7\xB9", "\xE2\xB7\xBA",
  "\xE2\xB7\xBB", "\xE2\xB7\xBC", "\xE2\xB7\xBD", "\xE2\xB7\xBE", "\xE2\xB7\xBF", "\xEA\x99\xAF", "\xEA\x99\xBC", "\xEA\x99\xBD",
  "\xEA\x9B\xB0", "\xEA\x9B\xB1", "\xEA\xA3\xA0", "\xEA\xA3\xA1", "\xEA\xA3\xA2", "\xEA\xA3\xA3", "\xEA\xA3\xA4", "\xEA\xA3\xA5",
}

local bufstate = {}
local next_id = 100
local hl_ns = vim.api.nvim_create_namespace("pdf_kitty")

local function apc(body)
  return "\x1b_G" .. body .. "\x1b\\"
end

local function emit(data)
  io.write(data)
  io.flush()
end

local function ph_line(cols, row)
  if cols <= 0 then return "" end
  local t = { PH .. (DIACRITICS[row + 1] or "") }
  for _ = 2, cols do t[#t + 1] = PH end
  return table.concat(t)
end

local function hl_for_id(id)
  local name = string.format("PdfKittyImg%d", id)
  local r = bit.band(bit.rshift(id, 16), 0xFF)
  local g = bit.band(bit.rshift(id,  8), 0xFF)
  local b = bit.band(id, 0xFF)
  vim.api.nvim_set_hl(0, name, { fg = r * 65536 + g * 256 + b })
  return name
end

local function page_count(pdf)
  local out = vim.fn.system({ "pdfinfo", pdf })
  local n = out:match("Pages:%s+(%d+)")
  return n and tonumber(n) or 0
end

local function ensure_png(s, page)
  if s.png_cache[page] then return s.png_cache[page] end
  local prefix = s.cache_dir .. "/p" .. page
  vim.fn.system({
    "pdftoppm", "-png", "-r", "200",
    "-f", tostring(page), "-l", tostring(page),
    "-singlefile", s.pdf, prefix,
  })
  local f = prefix .. ".png"
  if vim.fn.filereadable(f) == 1 then
    s.png_cache[page] = f
    return f
  end
  return nil
end

local function render(buf)
  local s = bufstate[buf]
  if not s then return end
  local win = vim.fn.bufwinid(buf)
  if win == -1 then return end

  local cols = vim.api.nvim_win_get_width(win)
  local rows = vim.api.nvim_win_get_height(win)

  if s.img_id and s.rcols == cols and s.rrows == rows and s.rpage == s.current then
    return
  end

  local png = ensure_png(s, s.current)
  if not png then
    vim.notify("Failed to render page " .. s.current, vim.log.levels.ERROR)
    return
  end

  local out = {}
  if s.img_id then
    out[#out + 1] = apc(string.format("a=d,d=I,i=%d,q=2;", s.img_id))
  end

  next_id = next_id + 1
  local id = next_id
  s.img_id = id
  s.rcols  = cols
  s.rrows  = rows
  s.rpage  = s.current

  out[#out + 1] = apc(string.format(
    "a=t,f=100,t=f,i=%d,q=2;%s", id, vim.base64.encode(png)
  ))
  out[#out + 1] = apc(string.format(
    "a=p,i=%d,U=1,c=%d,r=%d,q=2;", id, cols, rows
  ))
  emit(table.concat(out))

  local lines = {}
  for r = 0, rows - 1 do
    lines[r + 1] = ph_line(cols, r)
  end
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  vim.api.nvim_buf_clear_namespace(buf, hl_ns, 0, -1)
  local hl = hl_for_id(id)
  for i = 0, #lines - 1 do
    vim.api.nvim_buf_add_highlight(buf, hl_ns, hl, i, 0, -1)
  end

  vim.b[buf].pdf_page = s.current
end

function M.next(buf)
  local s = bufstate[buf]
  if not s or s.current >= s.total then return end
  s.current = s.current + 1
  render(buf)
end

function M.prev(buf)
  local s = bufstate[buf]
  if not s or s.current <= 1 then return end
  s.current = s.current - 1
  render(buf)
end

function M.go(buf, page)
  local s = bufstate[buf]
  if not s then return end
  s.current = math.max(1, math.min(page, s.total))
  render(buf)
end

function M.setup()
  vim.api.nvim_create_autocmd("BufReadCmd", {
    pattern = "*.pdf",
    callback = function(args)
      local pdf = vim.fn.fnamemodify(args.file, ":p")
      if vim.fn.filereadable(pdf) == 0 then
        vim.notify("PDF not readable: " .. pdf, vim.log.levels.ERROR)
        return
      end

      local total = page_count(pdf)
      if total == 0 then
        vim.notify("pdfinfo: no pages (install poppler?)", vim.log.levels.ERROR)
        return
      end

      local cache = vim.fn.tempname() .. "_pdf"
      vim.fn.mkdir(cache, "p")

      local buf = args.buf
      vim.bo[buf].buftype   = "nofile"
      vim.bo[buf].swapfile   = false
      vim.bo[buf].bufhidden  = "wipe"
      vim.bo[buf].filetype   = "pdf"

      bufstate[buf] = {
        pdf = pdf, total = total, current = 1,
        cache_dir = cache, png_cache = {}, img_id = nil,
      }
      vim.b[buf].pdf_page  = 1
      vim.b[buf].pdf_total = total

      local w = vim.fn.bufwinid(buf)
      if w ~= -1 then
        vim.wo[w].statusline =
          " PDF " .. vim.fn.fnamemodify(pdf, ":t")
          .. " | %{b:pdf_page}/%{b:pdf_total} | j/k:page  gg/G:first/last  q:quit"
      end

      local o = { buffer = buf, silent = true, nowait = true }
      vim.keymap.set("n", "j", function() M.next(buf) end, o)
      vim.keymap.set("n", "k", function() M.prev(buf) end, o)
      vim.keymap.set("n", "q", "<Cmd>bdelete!<CR>", o)
      vim.keymap.set("n", "G", function() M.go(buf, bufstate[buf].total) end, o)
      vim.keymap.set("n", "gg", function() M.go(buf, 1) end, o)

      local g = vim.api.nvim_create_augroup("PdfView_" .. buf, { clear = true })

      vim.api.nvim_create_autocmd("BufWipeout", { group = g, buffer = buf, callback = function()
        local st = bufstate[buf]
        if not st then return end
        if st.img_id then emit(apc(string.format("a=d,d=I,i=%d,q=2;", st.img_id))) end
        vim.fn.delete(st.cache_dir, "rf")
        bufstate[buf] = nil
      end })

      vim.api.nvim_create_autocmd({"VimResized", "WinResized"}, { group = g, callback = function()
        if bufstate[buf] and vim.fn.bufwinid(buf) ~= -1 then
          bufstate[buf].rpage = nil
          vim.schedule(function() render(buf) end)
        end
      end })

      vim.schedule(function() render(buf) end)
    end,
  })
end

return M
