return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "fredrikaverpil/neotest-golang",
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require("neotest-golang"),
                },
            })
        end,
        keys = {
            {
                "<leader>tt",
                function()
                    require("neotest").run.run(vim.fn.expand("%"))
                end,
                desc = "Run all tests in file",
            },
            {
                "<leader>tr",
                function()
                    require("neotest").run.run()
                end,
                desc = "Run nearest test",
            },
            {
                "<leader>td",
                function()
                    require("neotest").run.run({ suite = false, strategy = "dap" })
                end,
                desc = "Debug nearest test",
            },
            {
                "<leader>ts",
                function()
                    require("neotest").summary.toggle()
                end,
                desc = "Toggle test summary",
            },
            {
                "<leader>to",
                function()
                    require("neotest").output.open({ enter = true })
                end,
                desc = "Show test output",
            },
            {
                "<leader>tO",
                function()
                    require("neotest").output_panel.open()
                end,
                desc = "Show test output panel",
            },
            {
                "<leader>tJ",
                function()
                    require("neotest").jump.next({ status = "failed" })
                end,
                desc = "Jump to next failed test",
            },
            {
                "<leader>tK",
                function()
                    require("neotest").jump.prev({ status = "failed" })
                end,
                desc = "Jump to previous failed test",
            },
        },
    },
}