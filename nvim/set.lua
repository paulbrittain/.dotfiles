local home = vim.uv.os_homedir()
local undodir_path = home and (home .. "/.vim/undodir") or nil

local options = {
    nu = true,
    relativenumber = true,
    cursorline = true,

    splitright = true,

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

vim.filetype.add({ extension = { mjs = 'javascript', cjs = 'javascript' } })

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'json' },
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
        vim.opt_local.shiftwidth = 2
    end,
})

--  not sure where to save config like this. keeping it here for now.
vim.api.nvim_create_autocmd('textyankpost', {
    desc = "highlight when yanking text",
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})
