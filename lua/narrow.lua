local M = {}

local narrow = { left = nil, right = nil, width = 84 }

local function pad_buf()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  return buf
end

local function pad_width()
  return math.max(1, math.floor((vim.o.columns - narrow.width - 2) / 2))
end

local function style(win)
  for opt, val in pairs({ number = false, relativenumber = false, cursorline = false, signcolumn = "no", winfixwidth = true }) do
    vim.wo[win][opt] = val
  end
end

local function close()
  for _, key in ipairs({ "left", "right" }) do
    local w = narrow[key]
    if w and vim.api.nvim_win_is_valid(w) then vim.api.nvim_win_close(w, true) end
    narrow[key] = nil
  end
end

local function open()
  local main = vim.api.nvim_get_current_win()
  local pad = pad_width()

  vim.cmd("leftabove vsplit")
  narrow.left = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(narrow.left, pad_buf())
  style(narrow.left)
  vim.api.nvim_win_set_width(narrow.left, pad)

  vim.api.nvim_set_current_win(main)
  vim.cmd("rightbelow vsplit")
  narrow.right = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(narrow.right, pad_buf())
  style(narrow.right)
  vim.api.nvim_win_set_width(narrow.right, pad)

  vim.api.nvim_set_current_win(main)
end

function M.toggle()
  if narrow.left then close() else open() end
end

function M.setup()
  vim.api.nvim_create_autocmd("VimResized", {
    callback = function()
      if not narrow.left then return end
      local pad = pad_width()
      if vim.api.nvim_win_is_valid(narrow.left) then vim.api.nvim_win_set_width(narrow.left, pad) end
      if vim.api.nvim_win_is_valid(narrow.right) then vim.api.nvim_win_set_width(narrow.right, pad) end
    end,
  })

  -- If a pad window gets closed some other way (:only, manual :q), drop the
  -- stale handle so a later toggle doesn't try to close an invalid window.
  vim.api.nvim_create_autocmd("WinClosed", {
    callback = function(args)
      local id = tonumber(args.match)
      if narrow.left == id then narrow.left = nil end
      if narrow.right == id then narrow.right = nil end
    end,
  })
end

return M
