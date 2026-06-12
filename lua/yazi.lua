local M = {}

local config_home = vim.fn.stdpath("config") .. "/lua"

-- yazi emits `search://<session>:<line>:<col>//<absolute path>` from
-- `search --via=rg` hits via --chooser-file. Strip to a plain path and
-- surface the line:col for cursor placement.
local function parse_chosen(s)
  local line, col, path = s:match("^search://[^:]+:(%d+):(%d+)/(/.+)$")
  if path then
    return path, tonumber(line), tonumber(col)
  end
  return s, nil, nil
end

local function _launch(dir, prev_buf)
  local tmp = vim.fn.tempname()
  vim.cmd("enew")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  vim.fn.termopen({ "yazi", "--chooser-file", tmp, dir }, {
    env = { YAZI_CONFIG_HOME = config_home },
    on_exit = function()
      vim.schedule(function()
        local chosen
        if vim.fn.filereadable(tmp) == 1 then
          local lines = vim.fn.readfile(tmp)
          if #lines > 0 and lines[1] ~= "" then
            chosen = lines[1]
          end
        end
        vim.fn.delete(tmp)
        if chosen then
          local path, line, col = parse_chosen(chosen)
          vim.cmd("edit " .. vim.fn.fnameescape(path))
          if line then
            pcall(vim.api.nvim_win_set_cursor, 0, { line, math.max((col or 1) - 1, 0) })
          end
        else
          if prev_buf and vim.api.nvim_buf_is_valid(prev_buf)
            and vim.api.nvim_buf_get_name(prev_buf) ~= "" then
            vim.api.nvim_win_set_buf(0, prev_buf)
          else
            vim.cmd("enew")
          end
        end
      end)
    end,
  })
  vim.cmd("startinsert")
end

function M.open()
  local prev_buf = vim.api.nvim_get_current_buf()
  local dir
  local bufname = vim.api.nvim_buf_get_name(prev_buf)
  if bufname ~= "" and vim.fn.filereadable(bufname) == 1 then
    dir = vim.fn.fnamemodify(bufname, ":p:h")
  else
    dir = vim.fn.getcwd()
  end
  _launch(dir, prev_buf)
end

function M.open_in(dir)
  _launch(dir, nil)
end

function M.setup()
  vim.api.nvim_create_autocmd("BufEnter", {
    callback = function(args)
      local name = vim.api.nvim_buf_get_name(args.buf)
      if name ~= "" and vim.fn.isdirectory(name) == 1 then
        vim.schedule(function()
          M.open_in(name)
          if vim.api.nvim_buf_is_valid(args.buf) then
            pcall(vim.api.nvim_buf_delete, args.buf, { force = true })
          end
        end)
      end
    end,
  })
end

return M
