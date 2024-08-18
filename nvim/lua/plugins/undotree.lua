return {
    {
      "mbbill/undotree",
      config = function()
        -- Key mapping for toggling undotree
        vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { noremap = true, silent = true })
      end,
    }
  }
  