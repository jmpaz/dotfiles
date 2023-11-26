-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

--- General
vim.opt.clipboard = { exclude = ".*" }

--- Neovide
vim.g.neovide_scale_factor = 0.8
vim.g.neovide_hide_mouse_when_typing = true
vim.g.neovide_refresh_rate = 144
vim.g.neovide_refresh_rate_idle = 5
