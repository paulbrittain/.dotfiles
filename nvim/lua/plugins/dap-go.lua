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
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio"
        },
        event = 'VeryLazy',
        config = function()
            require('dapui').setup()
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
        },
        config = function()
            local services = {
                { name = "workflow", port = 31000 },
                { name = "report", port = 38000 },
                { name = "billing", port = 32000 },
                { name = "configuration", port = 44000 },
                { name = "render", port = 34000 },
            }

            local function get_debug_config(service_name, port)
                return {
                    type = "go",
                    name = service_name,
                    request = "attach",
                    mode = "remote",
                    substitutePath = {
                        {
                            from = "${workspaceFolder}/services/" .. service_name:lower(),
                            to = "git.helio.dev/helio/core/services/" .. service_name:lower(),
                        },
                    },
                    port = port,
                }
            end


            local dap_configurations = {}
            for _, service in ipairs(services) do
                table.insert(dap_configurations, get_debug_config(service.name, service.port))
            end

            require("dap-go").setup({
                dap_configurations = dap_configurations,
                delve = {
                    port = "${port}",  -- This will be replaced dynamically
                },
            })

            local function debug_service(service_name)
                for _, config in ipairs(dap_configurations) do
                    if config.name:lower() == service_name:lower() then
                        require("dap").run(config)
                        return
                    end
                end
                print("Service not found: " .. service_name)
            end

            local actions = require('telescope.actions')
            local action_state = require('telescope.actions.state')
            local pickers = require('telescope.pickers')
            local finders = require('telescope.finders')
            local config = require('telescope.config').values

            local function debug_service_picker(opts)
                opts = opts or {}
                pickers.new(opts, {
                    prompt_title = "Debug Service",
                    finder = finders.new_table {
                        results = services,
                        entry_maker = function(entry)
                            return {
                                value = entry,
                                display = entry.name .. " " .. "(Port: " .. entry.port .. ")",
                                ordinal = entry.name,
                            }
                        end,
                    },
                    sorter = config.generic_sorter(opts),
                     attach_mappings = function(prompt_bufnr, map)
                         actions.select_default:replace(function()
                             actions.close(prompt_bufnr)
                             local selection = action_state.get_selected_entry()
                             print("Selected service: " .. selection.value.name .. " on port " .. selection.value.port)
                             debug_service(selection.value.name)
                         end)
                         return true
                     end,
                }):find()
            end

            -- Command to open the Telescope picker
            vim.api.nvim_create_user_command("DebugServicePicker", debug_service_picker, {})

            -- Optional: Add a keymap to open the picker
            vim.keymap.set("n", "<leader>ds", debug_service_picker, { desc = "Debug Service Picker" })
        end,
    }
}
