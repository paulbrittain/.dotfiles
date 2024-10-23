local function get_workspace_path()
    if vim.fn.has('macunix') == 1 then
        return "~/Obsidian/helio/"
    else
        return "/home/sabana/personal/notes"
    end
end

return {
    "epwalsh/obsidian.nvim",
    version = "*",
    ft = "markdown",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    opts = {
        workspaces = {
            {
                name = "helio",
                path = get_workspace_path(),
            },
        },
        daily_notes = {
            folder = "dailies",
            default_tags = { "daily-notes" },
            date_format = "%d-%m-%Y",
        },
    },
}
