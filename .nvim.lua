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
            group_index = 0, -- lazydev takes precedence over nvim_lsp for lua globals
        })
        table.insert(opts.sources, { name = "nvim_lsp" })

        opts.snippet = {
            expand = function(args) vim.snippet.expand(args.body) end,
        }

        local cmp = require("cmp")
        -- Arrow keys highlight items without inserting them (like VSCode);
        -- the docs window scrolls with the mouse wheel, no keymap needed.
        opts.mapping = {
            ["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
            ["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
            ["<CR>"] = cmp.mapping.confirm({ select = false }),
        }
        return opts
    end,
    -- lazy.nvim only auto-calls `require(main).setup(opts)` when no `config`
    -- function is given; since lua_ls also needs registering here, cmp.setup
    -- must be called explicitly or nvim-cmp is never configured at all.
    config = function(_, opts)
        require("cmp").setup(opts)

        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        lsp("lua_ls", { cmd = { "lua-language-server" }, filetypes = { "lua" }, capabilities = capabilities })
    end
}

