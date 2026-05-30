return {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
    keys = {
        { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview open" },
        { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview history (file)" },
        { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview history (repo)" },
        { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diffview close" },
    },
    opts = {},
}
