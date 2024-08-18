return {
  {
    "VonHeikemen/lsp-zero.nvim",
    requires = {
      -- LSP Support
      {"neovim/nvim-lspconfig"},
      {"williamboman/mason.nvim"},
      {"williamboman/mason-lspconfig.nvim"},
    },
    config = function()
      local lsp = require("lsp-zero")

      lsp.preset("recommended")

      lsp.ensure_installed({
        'gopls',
      })

      -- Fix Undefined global 'vim'
      lsp.configure('lua-language-server', {
          settings = {
              Lua = {
                  diagnostics = {
                      globals = { 'vim' }
                  }
              }
          }
      })


      lsp.set_preferences({
          suggest_lsp_servers = true,
          sign_icons = {
              error = 'E',
              warn = 'W',
              hint = 'H',
              info = 'I'
          }
      })

      lsp.on_attach(function(client, bufnr)
        local opts = {buffer = bufnr, remap = false}

        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>lws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>lof", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
        vim.keymap.set("n", "<leader>lca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>lrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>lrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("i", "<leader>sh", function() vim.lsp.buf.signature_help() end, opts)
        vim.keymap.set("n", "<leader>sh", function() vim.lsp.buf.signature_help() end, opts)
      end)

      lsp.setup()

      vim.diagnostic.config({
          virtual_text = true
      })
    end,
  }
}
