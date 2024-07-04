return {
    -- Golang
    'fatih/vim-go',

    {
        'nvim-telescope/telescope.nvim', tag = '0.1.5',
        -- or                            , branch = '0.1.x',
        dependencies = { { 'nvim-lua/plenary.nvim' } }
    },

    {
        "nvim-telescope/telescope-file-browser.nvim",
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
    },

    {
        "danielfalk/smart-open.nvim",
      branch = "0.2.x",
      config = function()
        require"telescope".load_extension("smart_open")
      end,
      dependencies = {
        {"kkharji/sqlite.lua"},
        -- Only required if using match_algorithm fzf
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        -- Optional.  If installed, native fzy will be used when match_algorithm is fzy
        { "nvim-telescope/telescope-fzy-native.nvim" },
      }
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

    -- Todo comments
    -- use 'folke/todo-comments.nvim'

    -- grammar checking
    'rhysd/vim-grammarous',

    -- Nvim tree
    {
        'nvim-tree/nvim-tree.lua',
        dependencies = {
            'nvim-tree/nvim-web-devicons', -- optional
        },
    },

    -- Getting gud
    'ThePrimeagen/vim-be-good',

    -- Code screenshots
    "ellisonleao/carbon-now.nvim",

    -- Tmux integration
    { "christoomey/vim-tmux-navigator",
    },

  --   use({
  --       "epwalsh/obsidian.nvim",
  --       tag = "*",
  --       dependencies = {
  --       "nvim-lua/plenary.nvim",
  -- },
  -- config = function()
  --   require("obsidian").setup({
  --     workspaces = {
  --       {
  --         name = "personal",
  --         path = "~/vaults/personal",
  --       },
  --       {
  --         name = "helio",
  --         path = "~/vaults/work/helio",
  --       },
  --     },

  --     -- see below for full list of options 👇
  --   })
  -- end,
--})
}
