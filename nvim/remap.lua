vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Explorer (netrw)" })
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
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste over (keep register)" })

-- next greatest remap ever : asbjornHaland
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

vim.keymap.set({"n", "v"}, "<leader>d", [["_d]], { desc = "Delete to black hole" })

vim.keymap.set("n", "<C-c>", "<Cmd>nohlsearch<CR><Esc>", { noremap = true, silent = true })

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "LSP format buffer" })

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Next loclist" })
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Prev loclist" })

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word under cursor" })
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "chmod +x file" })

vim.keymap.set("n", "<leader><leader>", "<cmd>so<CR>", { desc = "Source current file" })
vim.keymap.set("n", "[b", ":bprev<CR>zz", { desc = "Prev buffer" })
vim.keymap.set("n", "]b", ":bnext<CR>zz", { desc = "Next buffer" })

vim.keymap.set("n", "=", [[<cmd>vertical resize +5<cr>]]) -- make the window biger vertically
vim.keymap.set("n", "+", [[<cmd>vertical resize -5<cr>]]) -- make the window smaller vertically
vim.keymap.set("n", "<", "<cmd>horizontal resize +2<cr>") -- make the window bigger horizontally by pressing shift and =
vim.keymap.set("n", ">", [[<cmd>horizontal resize -2<cr>]]) -- make the window smaller horizontally by pressing shift and -

