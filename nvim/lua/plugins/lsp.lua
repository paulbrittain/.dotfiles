return {
    {
        "VonHeikemen/lsp-zero.nvim",
        requires = {
            -- LSP Support
            {"neovim/nvim-lspconfig"},
            {"williamboman/mason.nvim"},
            {"williamboman/mason-lspconfig.nvim"},
        },
        config = function()
            local lsp = require("lsp-zero")

            lsp.preset("recommended")

            lsp.ensure_installed({
                'gopls',
                'pyright',
            })

            -- Fix Undefined global 'vim'
            lsp.configure('lua-language-server', {
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { 'vim' }
                        },
                        hint = {
                            enabled = true
                        },
                    },
                },
            })


            lsp.set_preferences({
                suggest_lsp_servers = true,
                sign_icons = {
                    error = 'E',
                    warn = 'W',
                    hint = 'H',
                    info = 'I'
                }
            })

            lsp.on_attach(function(client, bufnr)
                local opts = {buffer = bufnr, remap = false}

                vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
                vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
                vim.keymap.set("n", "<leader>lws", function() vim.lsp.buf.workspace_symbol() end, opts)
                vim.keymap.set("n", "<leader>lof", function() vim.diagnostic.open_float() end, opts)
                vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
                vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)

                opts.desc = "Show LSP code actions"
                vim.keymap.set("n", "<leader>lca", "<cmd>:Telescope lsp_code_actions<CR>", opts)

                opts.desc = "Show LSP references"
                vim.keymap.set("n", "<leader>lrr", "<cmd>:Telescope lsp_references<CR>", opts)

                opts.desc = "Rename"
                vim.keymap.set("n", "<leader>lrn", function() vim.lsp.buf.rename() end, opts)



            end)

            lsp.configure('pyright', {
                settings = {
                    python = {
                        analysis = {
                            autoSearchPaths = true,
                            useLibraryCodeForTypes = true,
                            diagnosticMode = 'workspace',
                            extraPaths = {
                                '/Users/paulbrittain/.pyenv/versions/thumbnailprocessor-env/lib/python3.11/site-packages'
                            }
                        }
                    }
                },
                before_init = function(_, config)
                    config.settings.python.pythonPath = '/Users/paulbrittain/.pyenv/versions/thumbnailprocessor-env/bin/python3'
                end,
            })

            lsp.setup()

            vim.diagnostic.config({
                virtual_text = true
            })
        end,
    }
}
