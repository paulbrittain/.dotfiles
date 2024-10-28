return {
    {
        "tpope/vim-fugitive",
        event = "VeryLazy",
        config = function()
            -- Key mappings
        vim.keymap.set("n", "<leader>gs", vim.cmd.Git, {desc = "Git Status"})
        vim.keymap.set("n", "<leader>gb", ":Telescope git_branches<CR>", {desc = "Telescope git branches"})

        -- Autocmd group and commands
        local Sabana_Fugitive = vim.api.nvim_create_augroup("Sabana_Fugitive", {})

        local autocmd = vim.api.nvim_create_autocmd
        autocmd("BufWinEnter", {
            group = Sabana_Fugitive,
            pattern = "*",
            callback = function()
                if vim.bo.ft ~= "fugitive" then
                    return
                end

                local bufnr = vim.api.nvim_get_current_buf()
                local opts = { buffer = bufnr, remap = false}
                vim.keymap.set("n", "<leader>p", function()
                    vim.cmd.Git('push')
                end, vim.tbl_extend("force", opts, { desc = "Git push" }))

                -- Rebase always
                vim.keymap.set("n", "<leader>P", function()
                    vim.cmd.Git({'pull', '--rebase'})
                end, vim.tbl_extend("force", opts, { desc = "Git pull rebase" }))

                -- Set up the branch push and tracking
                vim.keymap.set("n", "<leader>t", ":Git push -u origin ", vim.tbl_extend("force", opts, { desc = "Git push origin" }))
            end,
        })
      end,
    }
  }
