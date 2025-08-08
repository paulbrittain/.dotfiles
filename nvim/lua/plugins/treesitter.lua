return {
    {
        'nvim-treesitter/nvim-treesitter',
        lazy = false,
        branch = 'main',
        build = ":TSUpdate",
        init = function()
            local parser_installed = {
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

            vim.defer_fn(function() require("nvim-treesitter").install(parser_installed) end, 1000)
            require("nvim-treesitter").update()

            local parsersInstalled = require("nvim-treesitter.config").get_installed('parsers')
            for _, parser in pairs(parsersInstalled) do
              local filetypes = vim.treesitter.language.get_filetypes(parser)
              vim.api.nvim_create_autocmd({ "FileType" }, {
                pattern = filetypes,
                callback = function()
                  vim.treesitter.start()
                  vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                 end,
              })
            end
        end
    }
}
