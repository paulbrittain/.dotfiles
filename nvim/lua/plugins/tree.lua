return {
    "nvim-tree/nvim-tree.lua",
    requires = { "nvim-tree/nvim-web-devicons" },
    event = 'VeryLazy',
    config = function()
      -- Disable netrw at the very start
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      -- Setup nvim-tree
      require("nvim-tree").setup({
        update_focused_file = {
          enable = true,
        }
      })

      -- Key mapping for toggling nvim-tree
      --vim.api.nvim_set_keymap('n', '<leader>tr', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
    end,
  }

