return {
    {
        "mfussenegger/nvim-dap",
        event = 'VeryLazy',
        config = function()
            local dap, dapui = require("dap"), require("dapui")

            -- Debugging keymaps
            vim.keymap.set("n", "<F1>", dap.step_into, { desc = 'Debug: Step Into'})
            vim.keymap.set("n", "<F2>", dap.step_over, { desc = 'Debug: Step Over'})
            vim.keymap.set("n", "<F3>", dap.step_out, { desc = 'Debug: Step Out'})
            vim.keymap.set("n", "<F4>", dap.continue, { desc = 'Debug: Start/Continue'})
            vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint'})
            vim.keymap.set('n', '<leader>B', function()
                dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
            end, { desc = 'Debug: Set Breakpoint' })
            vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

            require('dap.ext.vscode').load_launchjs(nil, {})

            dap.listeners.after.event_initialized['dapui_config'] = dapui.open
            dap.listeners.before.event_terminated['dapui_config'] = dapui.close
            dap.listeners.before.event_exited['dapui_config'] = dapui.close
        end,
    },
    {
        "mfussenegger/nvim-dap-python",
        event = 'VeryLazy',
        config = function ()
            require('dap-python').setup("python")
        end
    },
    {
        "leoluz/nvim-dap-go",
        event = 'VeryLazy',
        dependencies = {
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
    },
}
