return {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = false,
    ft = "markdown",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    opts = {
        workspaces = {
            {
                name = "helio",
                path = "~/Obsidian/helio/",
            },
        },
        daily_notes = {
            folder = "dailies",
            default_tags = { "daily-notes" },
            date_format = "%d-%m-%Y",
        },
    },
}
