-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.cmd([[set guicursor= ]])

vim.opt.tabstop = 2
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.relativenumber = false
vim.opt.number = true
vim.opt.ignorecase = true
vim.opt.scrolloff = 8
vim.opt.cursorline = true
vim.cmd([[
    set conceallevel=0
    set concealcursor=""
]])
