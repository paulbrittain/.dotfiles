return {
    "kylechui/nvim-surround",
    version = "*", -- stable version
    event = "VeryLazy",
    config = function()
        require("nvim-surround").setup({
            keymaps = {
                -- Add
                normal          = "s",   -- Add surrounding (normal mode)
                normal_cur      = "ss",  -- Add surrounding for current word
                normal_line     = "S",   -- Surround current line
                normal_cur_line = "SS",  -- Surround current line (whole)
                visual          = "s",   -- Surround selection (visual mode)
                visual_line     = "S",   -- Surround visual line
                insert          = "<C-g>s",  -- Insert mode: Add surrounding
                insert_line     = "<C-g>S",  -- Insert mode: Add line surrounding

                -- Delete / Change
                delete = "sd",  -- Delete surrounding
                change = "sc",  -- Change surrounding
            },
        })
    end,
}
