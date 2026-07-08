local plugin, lsp = ...

plugin {
    "folke/lazydev.nvim",
    config = function()
        require("lazydev").setup({
            library = {
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        })
    end,
}

plugin {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
        local cmp = require("cmp")
        cmp.setup({
            sources = {
                -- lazydev takes precedence over nvim_lsp for lua globals
                { name = "lazydev", group_index = 0 },
                { name = "nvim_lsp" },
            },
            snippet = {
                expand = function(args) vim.snippet.expand(args.body) end,
            },
            -- Arrow keys highlight items without inserting them (like VSCode);
            -- the docs window scrolls with the mouse wheel, no keymap needed.
            mapping = {
                ["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
                ["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
                ["<CR>"] = cmp.mapping.confirm({ select = false }),
            },
        })

        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        lsp("lua_ls", {
            cmd = { "lua-language-server" },
            filetypes = { "lua" },
            capabilities = capabilities,
        })
    end,
}
