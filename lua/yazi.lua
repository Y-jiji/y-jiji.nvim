local M = {}

local function _launch(dir, prev_buf)
  local tmp = vim.fn.tempname()
  vim.cmd("enew")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  vim.fn.termopen({ "yazi", "--chooser-file", tmp, dir }, {
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
          vim.cmd("edit " .. vim.fn.fnameescape(chosen))
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
