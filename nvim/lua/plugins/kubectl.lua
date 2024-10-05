return {
  {
    "ramilito/kubectl.nvim",
    lazy = true,
    config = function()
      require("kubectl").setup({
      })
    end,
    opts = {
        vim.keymap.set("n", "<leader>ku", '<cmd>lua require("kubectl").toggle()<cr>', { noremap = true, silent = true })
    }
  },
}
