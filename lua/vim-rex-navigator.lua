local M = {}

local WINCMD = { left = 'h', down = 'j', up = 'k', right = 'l' }

local function swap_with(target)
  local current = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_win_get_buf(current)
  local target_buf = vim.api.nvim_win_get_buf(target)
  local current_view = vim.api.nvim_win_call(current, vim.fn.winsaveview)
  local target_view = vim.api.nvim_win_call(target, vim.fn.winsaveview)

  vim.api.nvim_win_set_buf(current, target_buf)
  vim.api.nvim_win_set_buf(target, current_buf)
  vim.api.nvim_win_call(current, function() vim.fn.winrestview(target_view) end)
  vim.api.nvim_win_call(target, function() vim.fn.winrestview(current_view) end)

  vim.api.nvim_set_current_win(target)
end

function M.move(dir)
  local current = vim.api.nvim_get_current_win()
  local target = vim.fn.win_getid(vim.fn.winnr(WINCMD[dir]))
  if target ~= 0 and target ~= current then
    swap_with(target)
  elseif vim.env.REX_SESSION then
    vim.system({ 'rex', 'do', 'vim_rex_move', 'direction=' .. dir })
  end
end

function M.navigate(dir)
  local win = vim.api.nvim_get_current_win()
  vim.cmd('wincmd ' .. WINCMD[dir])
  if win == vim.api.nvim_get_current_win() and vim.env.REX_SESSION then
    vim.system({ 'rex', 'do', 'vim_rex_focus', 'direction=' .. dir })
  end
end

function M.setup(opts)
  opts = opts or {}

  if opts.focus ~= false then
    vim.keymap.set({ 'n', 't' }, '<M-D-Left>', function() M.navigate('left') end)
    vim.keymap.set({ 'n', 't' }, '<M-D-Down>', function() M.navigate('down') end)
    vim.keymap.set({ 'n', 't' }, '<M-D-Up>', function() M.navigate('up') end)
    vim.keymap.set({ 'n', 't' }, '<M-D-Right>', function() M.navigate('right') end)
  end

  if opts.move ~= false then
    vim.keymap.set({ 'n', 't' }, '<S-M-D-Left>', function() M.move('left') end)
    vim.keymap.set({ 'n', 't' }, '<S-M-D-Down>', function() M.move('down') end)
    vim.keymap.set({ 'n', 't' }, '<S-M-D-Up>', function() M.move('up') end)
    vim.keymap.set({ 'n', 't' }, '<S-M-D-Right>', function() M.move('right') end)
  end

  if opts.close ~= false then vim.keymap.set({ 'n', 't' }, '<D-w>', '<cmd>confirm quit<cr>') end
end

return M
