return {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = "nvim-treesitter/nvim-treesitter",
    branch = 'main',
    opts = {
		select = {
			lookahead = true,
			-- `true` would even remove line breaks from charwise objects,
			-- thus staying with `false`
			include_surrounding_whitespace = false,
		},
	},
}
