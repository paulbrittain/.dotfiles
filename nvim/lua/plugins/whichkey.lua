return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 300
    end,
    opts = {
        preset = "modern",
        -- Popup delay (ms). Plugin-triggered popups show instantly.
        delay = function(ctx)
            return ctx.plugin and 0 or 200
        end,
        -- Teach built-in vim keys too: g/z prefixes, []/[] motions,
        -- registers ("), marks ('), windows (<c-w>), operators, text objects.
        plugins = {
            marks = true,
            registers = true,
            spelling = { enabled = true, suggestions = 20 },
            presets = {
                operators = true,
                motions = true,
                text_objects = true,
                windows = true,
                nav = true,
                z = true,
                g = true,
            },
        },
        -- Prefix group labels: names the menus shown on <leader> + wait.
        spec = {
            { "<leader>g", group = "git" },
            { "<leader>h", group = "git hunks" },
            { "<leader>p", group = "pickers / project" },
            { "<leader>d", group = "database (dadbod)" },
            { "<leader>t", group = "test / toggle" },
            { "<leader>x", group = "diagnostics / quickfix" },
            { "<leader>c", group = "code (trouble)" },
            { "<leader>o", group = "github (octo)" },
            { "<leader>v", group = "python venv" },
            { "<leader>l", group = "lsp / list" },
        },
    },
}
