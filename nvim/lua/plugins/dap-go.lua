return {
    "leoluz/nvim-dap-go",
    event = 'VeryLazy',
    dependencies = {
        "mfussenegger/nvim-dap",
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim",  -- required by Telescope
        "paulbrittain/nvim-dap-go-mono.nvim",
    },
    config = function()
        local dap_go_service_debug = require("nvim-dap-go-mono")

        dap_go_service_debug.setup({
            services = {
                { name = "workflow", port = 31000 },
                { name = "report", port = 38000 },
                { name = "billing", port = 32000 },
                { name = "configuration", port = 44000 },
                { name = "render", port = 34000 },
                { name = "storage", port = 43000 },
                { name = "event", port = 45000 },
            },
            substitution_path = "${workspaceFolder}/services/",
            remote_path_prefix = "git.helio.dev/helio/core/services/"
        })

        require("dap-go").setup({
            dap_configurations = dap_go_service_debug.generate_debug_dap_configurations(),
            delve = {
                port = "${port}",
            },
        })

        -- just for fun, I included my own telescope picker
        vim.keymap.set("n", "<leader>ds", dap_go_service_debug.debug_service_picker, { desc = "Debug Service Picker" })

    end,
}
