return {
    "rcarriga/nvim-dap-ui",
    dependencies = {
        "mfussenegger/nvim-dap",
        "nvim-neotest/nvim-nio",
        "theHamsta/nvim-dap-virtual-text"
    },
    event = 'VeryLazy',
    config = function()
        require('dapui').setup()
        require("nvim-dap-virtual-text").setup()
    end,
}

