-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- OSC52
vim.keymap.set("n", "<leader>+", require("osc52").copy_operator, { expr = true })
vim.keymap.set("n", "<leader>++", "<leader>c_", { remap = true })
vim.keymap.set("v", "<leader>+", require("osc52").copy_visual)
