return {
    {
        'nvim-telescope/telescope.nvim', tag = '0.1.8',
        requires = {{"nvim-lua/plenary.nvim"}, {"nvim-telescope/telescope-file-browser.nvim"}},
        config = function()
            local builtin = require('telescope.builtin')
            local actions = require('telescope.actions')

            -- Disable default vim-go key mappings.
            vim.cmd [[let g:go_def_mapping_enabled = 0]]

            -- Key mappings for telescope
            vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
            vim.keymap.set('n', '<C-p>', builtin.git_files, {})
            vim.keymap.set('n', '<leader>ps', ':Telescope live_grep<CR>')
            vim.keymap.set('n', '<leader>pp', builtin.current_buffer_fuzzy_find, {})
            vim.keymap.set('n', '<leader>pc', builtin.commands, {})
            vim.keymap.set('n', '<leader>ph', builtin.command_history, {})
            vim.keymap.set('n', '<leader>po', builtin.oldfiles, {})
            vim.keymap.set('n', '<leader>pr', ':Telescope resume<CR>')
            vim.keymap.set('n', '<space>fb', function()
                require('telescope').extensions.file_browser.file_browser({
                    path = vim.fn.expand('%:p:h'),
                    select_buffer = true,
                    hidden = true,
                    respect_gitignore = false,
                    git_status = false,
                })
            end)
            vim.keymap.set('n', '<leader>fw', ':Telescope grep_string<CR>')
            vim.keymap.set('n', '<leader>pn', function()
                builtin.find_files { cwd = vim.fn.stdpath 'config' }
            end, { desc = 'Search Neovim Files'})

            -- Telescope setup
            require("telescope").setup {
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
            }
        end,
    },
    {
        "nvim-telescope/telescope-ui-select.nvim",
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

