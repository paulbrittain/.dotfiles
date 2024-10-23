return {
  {
    "ramilito/kubectl.nvim",
    lazy = true,
    dir = "~/personal/kubectl.nvim",
    config = function()
      require("kubectl").setup({
      })
    end,
    opts = {
        vim.keymap.set("n", "<leader>ku", '<cmd>lua require("kubectl").toggle()<cr>', { noremap = true, silent = true }),
        vim.keymap.set("n", "<leader>kc", '<cmd>Kubectx<cr>', { noremap = true, silent = true })
    }
  },
}
