local plugin, lsp = ...

plugin {
    "folke/lazydev.nvim",
    ft = "lua", -- Only load this plugin when editing Lua files
    opts = {
        library = {
            -- Load luvit types when the `vim.uv` word is found
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
    },
}

plugin {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    opts = function(_, opts)
        opts.sources = opts.sources or {}
        table.insert(opts.sources, {
            name = "lazydev",
            group_index = 0,
        })
    end,
    config = function(_, opts)
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        lsp("lua_ls", { cmd = { "lua-language-server" }, capabilities = capabilities })
    end
}

