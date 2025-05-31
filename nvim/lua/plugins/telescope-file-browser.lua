return {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-fzf-native.nvim",
    },
    keys = {
        {
            "<space>fb",
            function()
                require("telescope").extensions.file_browser.file_browser({
                    path = vim.fn.expand("%:p:h"),
                    select_buffer = true,
                    hidden = true,
                    respect_gitignore = false,
                    git_status = false,
                })
            end,
            desc = "Telescope file browser",
        },
    },
    config = function()
        local actions = require("telescope.actions")
        require("telescope").setup({
            defaults = {
                layout_strategy = "vertical",
                layout_config = {
                    prompt_position = "top",
                },
                sorting_strategy = "ascending",
                vimgrep_arguments = {
                    "rg",
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--smart-case",
                    "--hidden",
                    "--glob=!.git/*",
                },
                mappings = {
                    i = {
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,
                    },
                },
            },
            extensions = {
                fzf = {},
            },
        })

        require("telescope").load_extension("fzf")
        require("telescope").load_extension("file_browser")
    end,
}
