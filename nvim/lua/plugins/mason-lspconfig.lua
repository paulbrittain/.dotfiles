return {
    'neovim/nvim-lspconfig',
    dependencies = {
        'folke/lazydev.nvim',
        'saghen/blink.cmp'
    },
    config = function()
        local blink = require('blink.cmp')
        local fzf_lua = require('fzf-lua')

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("lsp_keymaps", { clear = true }),
            callback = function(args)
                local opts = { buffer = args.buf }
                vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
                vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
                vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
                vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
                vim.keymap.set('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
                vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
                vim.keymap.set('n', '<leader>lrn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
                vim.keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
                vim.keymap.set("n", "gr", fzf_lua.lsp_references, opts)
            end,
        })

        local capabilities = blink.get_lsp_capabilities()

        vim.lsp.config("*", { capabilities = capabilities })
        vim.lsp.config("ts_ls", {
          root_markers = { "jsconfig.json", "tsconfig.json", ".git" },
        })
        vim.lsp.config("basedpyright", {
            settings = {
                basedpyright = {
                  pythonVersion = "3.11",
                  analysis = {
                    diagnosticMode = "openFilesOnly",
                    inlayHints = {
                      callArgumentNames = true
                    }
                  }
                }
              }
        })

        require("mason-lspconfig").setup {
          ensure_installed = { "bashls", "lua_ls", "biome", "ts_ls" },
          automatic_enable = true
        }
    end
}
