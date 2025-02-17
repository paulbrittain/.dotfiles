local home = vim.loop.os_homedir() -- More reliable than os.getenv("HOME")
local undodir_path = home and (home .. "/.vim/undodir") or nil

local options = {
    nu = true,
    relativenumber = true,
    cursorline = true,

    tabstop = 4,
    softtabstop = 4,

    shiftwidth = 4,
    expandtab = true,

    smartindent = true,

    wrap = true,

    swapfile = false,
    backup = false,

    undodir = undodir_path,
    undofile = true,

    hlsearch = true,
    incsearch = true,
    ignorecase = true,
    smartcase = true,

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

--  not sure where to save config like this. keeping it here for now.
vim.api.nvim_create_autocmd('textyankpost', {
    desc = "highlight when yanking text",
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})
