return {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    dependencies = {
        "mfussenegger/nvim-dap-python",
    },
    keys = {
        { "<leader>dPt", function() require('dap-python').test_method() end, desc = "Debug Method" },
        { "<leader>dPc", function() require('dap-python').test_class() end, desc = "Debug Class" },
    },
    config = function()
        require("dap-python").setup("uv")
    end,
}
