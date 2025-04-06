return {
    "ibhagwan/fzf-lua",
    opts = {},
    config = function()
        require('fzf-lua').setup({
            defaults = {
                git_icons = false,
                file_icons = false,
                color_icons = false
            },
        })

        local fzf = require("fzf-lua")

        -- Key mappings for FzfLua
        vim.keymap.set('n', '<leader>pf', fzf.files, {desc = "FzfLua find files"})
        vim.keymap.set('n', '<leader>ps', fzf.live_grep, {desc = "FzfLua live grep project"})
        vim.keymap.set('n', '<leader>pc', fzf.commands, {desc = "FzfLua commands"})
        vim.keymap.set('n', '<leader>ph', fzf.command_history, {desc = "FzfLua cmd hist"})
        vim.keymap.set('n', '<leader>po', fzf.oldfiles, {desc = "FzfLua old files"})
        vim.keymap.set('n', '<leader>pr', fzf.resume, {desc = "FzfLua resume"})
        vim.keymap.set('n', '<leader>gc', fzf.git_commits, {desc = "Git commits"})
        vim.keymap.set('n', '<leader>pn', function()
            fzf.files { cwd = vim.fn.stdpath 'config' }
        end, { desc = "FzfLua Neovim Files"})
        vim.keymap.set('n', '<leader>fb', function()
            fzf.files({
                cwd = vim.fn.stdpath('config'),
                previewer = "builtin", -- add this back
                actions = {
                    ['default'] = require('fzf-lua.actions').file_edit,
                    ['backspace'] = require('fzf-lua.actions').file_up,
                },
                winopts = {
                    preview = {
                        layout = "horizontal",
                        vertical = "up:50%",
                    },
                },
            })
        end, { desc = "FzfLua Simulated File Browser" })

    end,
}
