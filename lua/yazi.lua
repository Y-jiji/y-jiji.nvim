local M = {}

local config_home = vim.fn.stdpath("config") .. "/lua"

-- A buffer's own name isn't always the real file under the cursor -- e.g.
-- mdforest's synthetic transcluded view. Such modules register a resolver
-- here; open() consults them before the buffer name so it still lands in the
-- real file's parent folder. Reverse dependency on purpose: yazi never learns
-- who registers, so it carries no knowledge of any particular plugin.
M.source_resolvers = {}

function M.register_source_resolver(fn)
  table.insert(M.source_resolvers, fn)
end

-- First registered resolver that yields a readable file for `buf`, else nil.
local function resolved_source(buf)
  for _, fn in ipairs(M.source_resolvers) do
    local ok, path = pcall(fn, buf)
    if ok and path and path ~= "" and vim.fn.filereadable(path) == 1 then
      return path
    end
  end
  return nil
end

-- yazi emits `search~?://<domain>:<uri>:<urn>//<absolute path>` from
-- `search --via=rg` hits via --chooser-file. The two numeric fields are
-- yazi's internal Loc offsets (uri/urn path-component boundaries), NOT
-- line/column — strip them and return the underlying path.
local function parse_chosen(s)
  return s:match("^search~?://[^:]+:%d+:%d+/(/.+)$") or s
end

local function _launch(path, prev_buf)
  local tmp = vim.fn.tempname()
  vim.cmd("enew")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  vim.fn.termopen({ "yazi", "--chooser-file", tmp, path }, {
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
          vim.cmd("edit " .. vim.fn.fnameescape(parse_chosen(chosen)))
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
  -- Hand yazi the file itself, not its folder: yazi opens the parent
  -- directory with that file hovered. Fall back to cwd when there's no file
  -- (an unnamed or synthetic buffer with no resolver match).
  local target
  local bufname = resolved_source(prev_buf) or vim.api.nvim_buf_get_name(prev_buf)
  if bufname ~= "" and vim.fn.filereadable(bufname) == 1 then
    target = vim.fn.fnamemodify(bufname, ":p")
  else
    target = vim.fn.getcwd()
  end
  _launch(target, prev_buf)
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
