return {
    "ray-x/go.nvim",
    dependencies = {  -- optional packages
        "ray-x/guihua.lua",
        "neovim/nvim-lspconfig",
        "nvim-treesitter/nvim-treesitter",
    },
    branch = "treesitter-main",
    opts = {
        lsp_cfg = false,   -- let mason-lspconfig/lspconfig handle gopls
        lsp_keymaps = true,
    },
    config = function(_, opts)
        require("go").setup(opts)

        -- Autoformat on save
        local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
        vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = "*.go",
            callback = function()
                require("go.format").goimports()
            end,
            group = format_sync_grp,
        })

        vim.keymap.set({ "n", "v" }, "<leader>lsa", function()
            vim.lsp.buf.code_action({
                desc = "LSP: Show code actions",
                silent = true,
            })
        end, { desc = "LSP: Extract to new function" })
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()', -- update binaries if needed
}
