return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/neotest-python",
        },
        config = function()
            require("neotest").setup({
              adapters = {
                require("neotest-python")({
                    runner = "pytest",
                    args = { "--log-level", "DEBUG" },
                }),
              },
            })
        end,
        keys = {
            {
                "<leader>tt",
                function()
                    require("neotest").run.run(vim.fn.expand("%"))
                end,
                desc = "Neotest: run file",
            },
            {
                "<leader>tr",
                function()
                    require("neotest").run.run()
                end,
                desc = "Neotest: run nearest",
            },
            {
                "<leader>td",
                function()
                    require("neotest").run.run({ suite = false, strategy = "dap" })
                end,
                desc = "Neotest: debug nearest",
            },
            {
                "<leader>ts",
                function()
                    require("neotest").summary.toggle()
                end,
                desc = "Neotest: toggle summary",
            },
            {
                "<leader>to",
                function()
                    require("neotest").output.open({ enter = true })
                end,
                desc = "Neotest: output",
            },
            {
                "<leader>tO",
                function()
                    require("neotest").output_panel.open()
                end,
                desc = "Neotest: output panel",
            },
            {
                "<leader>tJ",
                function()
                    require("neotest").jump.next({ status = "failed" })
                end,
                desc = "Neotest: next failed",
            },
            {
                "<leader>tK",
                function()
                    require("neotest").jump.prev({ status = "failed" })
                end,
                desc = "Neotest: prev failed",
            },
        },
    },
}
