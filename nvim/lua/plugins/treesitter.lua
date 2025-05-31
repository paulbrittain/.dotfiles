return {
    {
        'nvim-treesitter/nvim-treesitter',
        lazy = false,
        branch = 'main',
        build = ':TSUpdate',
        config = function()
            local ts = require('nvim-treesitter')

            local ensure_installed = {
                "python",
                "go",
                "c",
                "lua",
                "vim",
                "vimdoc",
                "query",
                "markdown_inline",
                "markdown",
            }

            ts.setup()
            ts.install(ensure_installed)
        end,
    }
}
