local M = {}

local WINCMD = { left = 'h', down = 'j', up = 'k', right = 'l' }

function M.navigate(dir)
  local win = vim.api.nvim_get_current_win()
  vim.cmd('wincmd ' .. WINCMD[dir])
  if win == vim.api.nvim_get_current_win() and vim.env.REX_SESSION then
    vim.system({ 'rex', 'do', 'vim_rex_focus', 'direction=' .. dir })
  end
end

function M.setup(opts)
  opts = opts or {}

  if opts.mappings == false then return end

  vim.keymap.set({ 'n', 't' }, '<M-D-Left>', function() M.navigate('left') end)
  vim.keymap.set({ 'n', 't' }, '<M-D-Down>', function() M.navigate('down') end)
  vim.keymap.set({ 'n', 't' }, '<M-D-Up>', function() M.navigate('up') end)
  vim.keymap.set({ 'n', 't' }, '<M-D-Right>', function() M.navigate('right') end)
  vim.keymap.set({ 'n', 't' }, '<D-w>', '<cmd>confirm quit<cr>')
end

return M
