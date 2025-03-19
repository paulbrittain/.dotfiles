return {
    {
        'nvim-telescope/telescope.nvim', tag = '0.1.8',
        requires = {{"nvim-lua/plenary.nvim"}, {"nvim-telescope/telescope-file-browser.nvim"}, {"nvim-telescope/telescope-fzf-native.nvim"}},
        config = function()
            local builtin = require('telescope.builtin')
            local actions = require('telescope.actions')

            -- Disable default vim-go key mappings.
            vim.cmd [[let g:go_def_mapping_enabled = 0]]

            -- Key mappings for telescope
            vim.keymap.set('n', '<leader><leader>', builtin.buffers, {desc = "Telescope buffer"})
            vim.keymap.set('n', '<leader>pf', builtin.find_files, {desc = "Telescope find files"})
            vim.keymap.set('n', '<C-p>', builtin.git_files, {desc = "Telescope git files"})
            vim.keymap.set('n', '<leader>ps', ':Telescope live_grep<CR>')
            vim.keymap.set('n', '<leader>pc', builtin.commands, {desc = "Telescope commands"})
            vim.keymap.set('n', '<leader>ph', builtin.command_history, {desc = "Telescope cmd hist"})
            vim.keymap.set('n', '<leader>po', builtin.oldfiles, {desc = "Telescope old files"})
            vim.keymap.set('n', '<leader>pd', builtin.man_pages, {desc = "Telescope documentation"})
            vim.keymap.set('n', '<leader>pr', ':Telescope resume<CR>', {desc = "Telescope resume"})
            vim.keymap.set('n', '<space>fb', function()
                require('telescope').extensions.file_browser.file_browser({
                    path = vim.fn.expand('%:p:h'),
                    select_buffer = true,
                    hidden = true,
                    respect_gitignore = false,
                    git_status = false,
                })
            end, {desc = "Telescope fb"})
            vim.keymap.set('n', '<leader>pn', function()
                builtin.find_files { cwd = vim.fn.stdpath 'config' }
            end, { desc = "Telescope Neovim Files"})

            -- Telescope setup
            require("telescope").setup {
                extensions = {
                    fzf = {}
                },
                defaults = {
                    layout_strategy = 'vertical',
                    layout_config = {
                        prompt_position = "top"  -- search bar at the top
                    },
                    sorting_strategy = "ascending",
                    vimgrep_arguments = {
                        'rg',
                        '--color=never',
                        '--no-heading',
                        '--with-filename',
                        '--line-number',
                        '--column',
                        '--smart-case',
                        '--hidden',
                        '--glob=!.git/*'
                    },
                    mappings = {
                        i = {
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                        },
                    },
                },
                require('telescope').load_extension('fzf')
            }
        end,
    },
    {
        "nvim-telescope/telescope-ui-select.nvim",
        lazy = true,
        config = function()
            require("telescope").setup({
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown {}
                    }
                }
            })
            require("telescope").load_extension("ui-select")
        end,
    }
}

