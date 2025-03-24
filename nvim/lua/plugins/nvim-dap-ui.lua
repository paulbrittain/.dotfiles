return {
    "rcarriga/nvim-dap-ui",
    dependencies = {
        "mfussenegger/nvim-dap",
        "nvim-neotest/nvim-nio",
        "theHamsta/nvim-dap-virtual-text"
    },
    event = 'VeryLazy',
    config = function()
    require('dapui').setup({
        layouts = { 
            {
                elements = {
                    { id = "scopes", size = 0.55 },
                    { id = "watches", size = 0.15 },
                    { id = "stacks", size = 0.15 },
                    { id = "breakpoints", size = 0.15 },
                },
                position = "left",
                size = 80 -- Increased from 40 to 80
            },
            {
                elements = {
                    { id = "repl", size = 0.5 },
                    { id = "console", size = 0.5 },
                },
                position = "bottom",
                size = 20 -- Increased from 10 to 20
            }
        }
    })
        require("nvim-dap-virtual-text").setup()
    end,
}

