return {
    {
        'nvim-telescope/telescope.nvim', tag = '0.1.5',
        -- or                            , branch = '0.1.x',
        dependencies = { { 'nvim-lua/plenary.nvim' } }
    },

    {
        "nvim-telescope/telescope-file-browser.nvim",
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
    },


    'nvim-treesitter/playground',
    'nvim-treesitter/nvim-treesitter-context',
    'mbbill/undotree',
    'tpope/vim-fugitive',

    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { { "nvim-lua/plenary.nvim" } }
    },

    {
        "VonHeikemen/lsp-zero.nvim",
        branch = "v1.x",
        dependencies = {
            -- LSP Support
            { "neovim/nvim-lspconfig" },
            { "williamboman/mason.nvim" },
            { "williamboman/mason-lspconfig.nvim" },

            -- Autocompletion
            { "hrsh7th/nvim-cmp" },
            { "hrsh7th/cmp-buffer" },
            { "hrsh7th/cmp-path" },
            { "saadparwaiz1/cmp_luasnip" },
            { "hrsh7th/cmp-nvim-lsp" },
            { "hrsh7th/cmp-nvim-lua" },

            -- Snippets
            { "L3MON4D3/LuaSnip" },
            { "rafamadriz/friendly-snippets" },
        }
    },

    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup {}
        end
    },

    -- Debugging
    'mfussenegger/nvim-dap',
    'leoluz/nvim-dap-go',
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" }
    },
    'theHamsta/nvim-dap-virtual-text',
    'nvim-telescope/telescope-dap.nvim',

    -- Theme
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        transparent_background = true,
    },

    "EdenEast/nightfox.nvim",
    "tjdevries/colorbuddy.nvim",

    --devicons
    'kyazdani42/nvim-web-devicons',

    -- Nvim tree
    {
        'nvim-tree/nvim-tree.lua',
        dependencies = {
            'nvim-tree/nvim-web-devicons', -- optional
        },
    },

    -- Tmux integration
    { "christoomey/vim-tmux-navigator",
    },
}
