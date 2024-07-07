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

          dap.listeners.after.event_initialized['dapui_config'] = dapui.open
          dap.listeners.before.event_terminated['dapui_config'] = dapui.close
          dap.listeners.before.event_exited['dapui_config'] = dapui.close
        end,
      },
      {
        "theHamsta/nvim-dap-virtual-text",
        event = 'VeryLazy',
        config = function()
          require('nvim-dap-virtual-text').setup()
        end,
      },
      {
        "rcarriga/nvim-dap-ui",
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
          opts = {
              dap_configurations = {
                  {
                      -- Must be "go" or it will be ignored by the plugin
                      type = "go",
                      name = "Workflow",
                      request = "attach",
                      mode = "remote",
                      substitutePath = {
                          {
                              from = "${workspaceFolder}",
                              to = "git.helio.dev/helio/core/services/workflow",
                          },
                      },
                  },
              },
              delve = {
                  port = 31000,
              },
          },
      }
  }
