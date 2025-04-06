return {
    "folke/noice.nvim",
    config = function()
        require("noice").setup({
            routes = {
                {
                    filter = {
                        event = 'msg_show',
                        any = {
                            { find = '%d+L, %d+B' },
                            { find = '; after #%d+' },
                            { find = '; before #%d+' },
                            { find = '%d fewer lines' },
                            { find = '%d more lines' },
                        },
                    },
                    opts = { skip = true },
                },
            },
            cmdline = {
                view = "cmdline"
            },
            lsp = {
                -- Enable LSP features
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                },
                hover = {
                    enabled = true,
                },
                signature = {
                    enabled = true,
                },
            },
        })
    end,
    dependencies = {
        "MunifTanjim/nui.nvim",
        -- OPTIONAL:
        --   `nvim-notify` is only needed, if you want to use the notification view.
        --   If not available, we use `mini` as the fallback
        --"rcarriga/nvim-notify",
    }
}
