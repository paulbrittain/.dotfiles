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
            opts.desc = "Show LSP references"
            vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
            vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
            vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
            vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
            vim.keymap.set('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
            vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
            vim.keymap.set('n', '<leader>lrn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
            vim.keymap.set('n', '<leader>lca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
            vim.keymap.set("n", "gr", fzf_lua.lsp_references, opts)
        end

        local capabilities = blink.get_lsp_capabilities()
        local lsp_defaults = {
          on_attach = lsp_attach,
          capabilities = capabilities,
        }

        vim.lsp.config("*", lsp_defaults)
        vim.lsp.config("basedpyright", lsp_defaults, {
            settings = {
                basedpyright = {
                    autoSearchPaths = true,
                    useLibraryCodeForTypes = true,
                    typeCheckingMode = "basic",
                    diagnosticMode = "workspace",
                },
            },
        })

        require("mason").setup()
        require("mason-lspconfig").setup {
          ensure_installed = { "gopls", "bashls", "lua_ls", "basedpyright" },
          automatic_enable = true
        }
    end
}
