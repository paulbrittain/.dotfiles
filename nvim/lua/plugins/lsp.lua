return {
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'folke/lazydev.nvim',
            'saghen/blink.cmp'
        },
        config = function()
            local blink = require('blink.cmp')
            local lspconfig = require('lspconfig')
            local fzf_lua = require('fzf-lua')
            local is_mac = vim.fn.has('mac') == 1

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


            -- Setup servers with custom configurations
            require('mason-lspconfig').setup_handlers({
                function(server_name)
                    lspconfig[server_name].setup({
                        on_attach = lsp_attach,
                        capabilities = capabilities
                    })
                end,
                pyright = function()
                    -- local python_path = is_mac 
                    --      and '/Users/paulbrittain/.pyenv/versions/thumbnailprocessor-env/bin/python3.11'
                    --      or '/home/sabana/helio/native-plugins/myenv/bin/python3.11'
                    --
                    -- local extra_paths = is_mac 
                    --      and {'/Users/paulbrittain/.pyenv/versions/thumbnailprocessor-env/lib/python3.11/site-packages/OpenImageIO'}
                    --      or {'home/sabana/helio/native-plugins/helio_submitter/max/pymxs.py'}

                    lspconfig.pyright.setup({
                        on_attach = lsp_attach,
                        capabilities = capabilities,
                        settings = {
                            python = {
                                analysis = {
                                    autoSearchPaths = true,
                                    useLibraryCodeForTypes = true,
                                    typeCheckingMode = "basic",
                                    diagnosticMode = 'workspace',
                                    -- extraPaths = extra_paths
                                }
                            }
                        },
                        -- before_init = function(_, config)
                        --     config.settings.python.pythonPath = python_path
                        -- end,
                    })
                end
            })
        end
    }
}
