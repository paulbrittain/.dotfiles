return {
    {
        "mfussenegger/nvim-dap",
        event = 'VeryLazy',
        dependencies = {
            {
                "mfussenegger/nvim-dap",
                "nvim-neotest/nvim-nio",
                "theHamsta/nvim-dap-virtual-text",
                "rcarriga/nvim-dap-ui",
            },
        },
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
            vim.keymap.set('n', '<space>?', function ()
                require("dapui").eval(nil, { enter  = true})
            end)

            vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

            require('dap.ext.vscode').load_launchjs(nil, {})

            dap.listeners.after.event_initialized['dapui_config'] = dapui.open
            -- dap.listeners.before.event_terminated['dapui_config'] = dapui.close
            -- dap.listeners.before.event_exited['dapui_config'] = dapui.close

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
}
