return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {
        "nvim-lua/plenary.nvim"
    },
    config = function()
        require("harpoon"):setup()
    end,
    keys = function()
        local harpoon = require("harpoon")
        local conf = require("telescope.config").values

        local function toggle_telescope(harpoon_files)
            local file_paths = {}

            -- Collect file paths from Harpoon's list
            for _, item in ipairs(harpoon_files.items) do
                table.insert(file_paths, item.value)
            end

            local function make_finder()
                local paths = {}

                -- Collect file paths again for Finder
                for _, item in ipairs(harpoon_files.items) do
                    table.insert(paths, item.value)
                end

                return require("telescope.finders").new_table({
                    results = paths,
                })
            end

            -- Create a new Telescope picker
            --require("telescope.pickers").new({}, {
            --    prompt_title = "Harpoon",
            --    finder = require("telescope.finders").new_table({
            --        results = file_paths,
            --    }),
            --    previewer = conf.file_previewer({}),
            --    sorter = conf.generic_sorter({}),
            --    attach_mappings = function(prompt_buffer_number, map)
            --        map("i", "<C-d>", function()
            --            local state = require("telescope.actions.state")
            --            local selected_entry = state.get_selected_entry()
            --            local current_picker = state.get_current_picker(prompt_buffer_number)

            --            -- Remove selected entry from Harpoon's list
            --            harpoon:list():remove(selected_entry)
            --            current_picker:refresh(make_finder())
            --        end)

            --        return true
            --    end,
            --}):find()
        end

        -- Define key mappings
        return {
            {
                "<C-e>",
                function()
                    harpoon.ui:toggle_quick_menu(harpoon:list())
                end,
                desc = "Harpoon (Telescope)",
            },

            {
                "<C-q>",
                function()
                    harpoon:list():add()
                end,
                desc = "Harpoon: Add",
            },

            {
                "<C-t>",
                function()
                    harpoon:list():select(1)
                end,
            },

            {
                "<C-n>",
                function()
                    harpoon:list():select(2)
                end,
            },
            {
                "<C-s>",
                function()
                    harpoon:list():select(3)
                end,
            },
        }
    end,
}
