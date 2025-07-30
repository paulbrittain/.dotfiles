return {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
        "mfussenegger/nvim-dap-python",
        -- stylua: ignore
        keys = {
            { "<leader>dPt", function() require('dap-python').test_method() end, desc = "Debug Method" },
            { "<leader>dPc", function() require('dap-python').test_class() end, desc = "Debug Class" },
        },
        config = function()
            require("dap-python").setup("uv")
            require('dap.ext.vscode').load_launchjs()
        end,
    },
}
