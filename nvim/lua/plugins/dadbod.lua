return {
    {
        "tpope/vim-dadbod",
        dependencies = {
            "kristijanhusak/vim-dadbod-ui",
            "kristijanhusak/vim-dadbod-completion",
        },
        cmd = { "DB", "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
        keys = {
            { "<leader>db", "<cmd>DBUIToggle<cr>", desc = "Dadbod: toggle UI" },
        },
        init = function()
            local creds_path = vim.fn.expand("~/.tmux-db-creds.json")
            if vim.fn.filereadable(creds_path) == 0 then
                return
            end
            local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(creds_path), "\n"))
            if not ok or type(decoded) ~= "table" then
                return
            end
            local function urlenc(s)
                return (s:gsub("[^A-Za-z0-9_.~-]", function(c)
                    return string.format("%%%02X", string.byte(c))
                end))
            end
            -- Decrypt an "age:<base64>" password using the SSH/age key. Plaintext
            -- is returned as-is; returns nil if decryption fails.
            local age_key = vim.fn.expand("~/.ssh/id_ed25519")
            local function decrypt_password(pw)
                if type(pw) ~= "string" or pw:sub(1, 4) ~= "age:" then
                    return pw
                end
                local out = vim.fn.system(
                    { "sh", "-c", "openssl base64 -d -A | age -d -i " .. vim.fn.shellescape(age_key) },
                    pw:sub(5)
                )
                if vim.v.shell_error ~= 0 then
                    return nil
                end
                return (out:gsub("\n$", ""))
            end
            local blocked = { ["prod-rw"] = true }
            local dbs = {}
            for name, c in pairs(decoded) do
                if not blocked[name] then
                    local password = decrypt_password(c.password)
                    if password == nil then
                        vim.notify(
                            "dadbod: failed to decrypt password for '" .. name .. "' (age/ssh key?)",
                            vim.log.levels.WARN
                        )
                    else
                        dbs[name] = string.format(
                            "postgres://%s:%s@%s:%d/%s",
                            urlenc(c.user), urlenc(password), c.host, c.port, c.database
                        )
                    end
                end
            end
            vim.g.dbs = dbs
        end,
    },
}
