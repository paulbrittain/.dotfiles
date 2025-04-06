return {
    'linux-cultist/venv-selector.nvim',
    branch = "regexp",
    dependencies = { 'neovim/nvim-lspconfig', 'ibhagwan/fzf-lua', 'mfussenegger/nvim-dap-python' },
    config = function()
        require('venv-selector').setup {
            settings = {
                options = {
                    picker = "fzf-lua"
                }
            }
        }
    end,
    -- event = 'VeryLazy', -- Optional: needed only if you want to type `:VenvSelect` without a keymapping
    keys = {
        -- Keymap to open VenvSelector to pick a venv.
        { '<leader>vs', '<cmd>VenvSelect<cr>' },
        -- Keymap to retrieve the venv from a cache (the one previously used for the same project directory).
        { '<leader>vc', '<cmd>VenvSelectCached<cr>' },
    },
}
