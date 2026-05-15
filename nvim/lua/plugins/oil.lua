return {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    config = function(_, opts)
        require('oil').setup(opts)
        vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Oil Open parent directory" })
    end,
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
}
