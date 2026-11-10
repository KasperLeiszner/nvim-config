vim.g.ai_cmp = false
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.scrolloff = 8

if vim.g.neovide then
  vim.o.guifont = "JetBrainsMono Nerd Font:h14"
  vim.g.neovide_input_macos_option_key_is_meta = "only_left"
  vim.g.neovide_cursor_animation_length = 0.05
  vim.g.neovide_scroll_animation_length = 0.15
  vim.g.neovide_remember_window_size = true
end

local dotnet_tools = vim.fn.expand("~/.dotnet/tools")
if not vim.env.PATH:find(dotnet_tools, 1, true) then
  vim.env.PATH = dotnet_tools .. ":" .. vim.env.PATH
end
