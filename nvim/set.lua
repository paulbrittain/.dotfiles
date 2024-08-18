local options = {
    guicursor = "",
    nu = true,
    relativenumber = true,
    
    tabstop = 4,
    softtabstop = 4,
    
    shiftwidth = 4,
    expandtab = true,
    
    smartindent = true,
    
    wrap = true,
    
    swapfile = false,
    backup = false,
    undodir = os.getenv("HOME") .. "/.vim/undodir",
    undofile = true,
    
    hlsearch = false,
    incsearch = true,
    
    termguicolors = true,
    
    scrolloff = 8,
    signcolumn = "yes",
    isfname = vim.opt.isfname:append("@-@"),
    
    updatetime = 50,
    
    conceallevel = 1,
    
    clipboard = 'unnamedplus',
}

for k, v in pairs(options) do
    vim.opt[k] = v
  end

--  Not sure where to save config like this. Keeping it here for now.
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = "Highlight when yanking text",
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})
