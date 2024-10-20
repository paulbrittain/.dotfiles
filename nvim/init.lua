local script_dir = vim.fn.expand('<sfile>:p:h')

-- Add the current directory to the package path
package.path = package.path .. ';' .. script_dir .. '/?.lua'

require("remap")
require("set")

-- General/Global LSP Configuration.
local lsp = vim.lsp

-- Workaround for a dumb Neovim dev decision that partially breaks Go lsp for Mac.
local make_client_capabilities = lsp.protocol.make_client_capabilities
function lsp.protocol.make_client_capabilities()
    local caps = make_client_capabilities()
    if not (caps.workspace or {}).didChangeWatchedFiles then
        vim.notify(
            'lsp capability didChangeWatchedFiles is already disabled',
            vim.log.levels.WARN
        )
    else
        caps.workspace.didChangeWatchedFiles = nil
    end

    return caps
end

-- Install Lazy.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Set the map leader directly after installing lazy, it's what it wants.
vim.g.mapleader = " "

-- I've turned this on to try get treesitter-text-objects to work. I should remove these lines in the future to test whether this actually did something good.
vim.cmd.filetype("on")
vim.cmd.filetype("plugin on")

-- Use all my plugins.
return require('lazy').setup('plugins')
