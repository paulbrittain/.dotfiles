vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Half screen jumping
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "n", "nzzzv", { desc = "Next Search Result Centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous Search Result Centered" })
vim.keymap.set("n", "*", "*zzzv", { desc = "Next Symbol Centered" })
vim.keymap.set("n", "#", "#zzzv", { desc = "Previous Symbol Centered" })
vim.keymap.set("n", "g*", "g*zzzv", { desc = "Next Symbol Search Centered" })
vim.keymap.set("n", "g#", "g#zzzv", { desc = "Reverse Symbol Search Centered" })

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

vim.keymap.set("n", "<C-c>", "<Cmd>nohlsearch<CR><Esc>", { noremap = true, silent = true })

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")

    vim.keymap.set("n", "<leader>h", ":bprev<CR>zz")
    vim.keymap.set("n", "<leader>l", ":bnext<CR>zz")
end)
