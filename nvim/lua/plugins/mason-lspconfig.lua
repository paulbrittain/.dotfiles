return {
    'neovim/nvim-lspconfig',
    dependencies = {
        'folke/lazydev.nvim',
        'saghen/blink.cmp'
    },
    config = function()
        local blink = require('blink.cmp')
        local fzf_lua = require('fzf-lua')

        local lsp_attach = function(client, bufnr)
            local opts = {buffer = bufnr}
            vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
            vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
            vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
            vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
            vim.keymap.set('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
            vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
            vim.keymap.set('n', '<leader>lrn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
            vim.keymap.set('n', '<leader>lca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
            vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
            vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
            opts.desc = "Show LSP references"
            vim.keymap.set("n", "gr", fzf_lua.lsp_references, opts)
        end

        local capabilities = blink.get_lsp_capabilities()

        vim.lsp.config("*", {
            capabilities = capabilities,
            on_attach = lsp_attach
        })
        vim.lsp.config("pyright", {
            settings = {
                python = {
                    analysis = {
                        autoSearchPaths = true,
                        useLibraryCodeForTypes = true,
                        typeCheckingMode = "basic",
                        diagnosticMode = "workspace",
                    },
                },
            },
        })

        require("mason").setup()
        require("mason-lspconfig").setup {
          ensure_installed = { "gopls", "bashls", "lua_ls", "pyright" },
          automatic_enable = true
        }
    end
}
