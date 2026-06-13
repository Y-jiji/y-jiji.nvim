-- Override leanls: use `lean --server` and force semantic tokens.
-- `lake serve` strips semanticTokensProvider; even `lean --server` doesn't
-- report the capability in a way Neovim parses, but the server DOES respond
-- to textDocument/semanticTokens requests. Force the capability via LspAttach.
return {
  cmd = function(dispatchers, config)
    local cwd = config.cmd_cwd
    if not cwd and config.root_dir and vim.uv.fs_realpath(config.root_dir) then
      cwd = config.root_dir
    end

    local env = nil
    local has_lake = cwd
      and (vim.uv.fs_stat(vim.fs.joinpath(cwd, 'lakefile.lean'))
        or vim.uv.fs_stat(vim.fs.joinpath(cwd, 'lakefile.toml')))
    if has_lake then
      local r = vim.system({ 'lake', 'env', 'sh', '-c', 'echo $LEAN_PATH' }, { cwd = cwd }):wait()
      if r.code == 0 then
        local lp = r.stdout:gsub('%s+$', '')
        if #lp > 0 then
          env = { LEAN_PATH = lp }
        end
      end
    end

    return vim.lsp.rpc.start({ 'lean', '--server', config.root_dir }, dispatchers, {
      cwd = cwd,
      env = env,
      detached = config.detached,
    })
  end,
}
