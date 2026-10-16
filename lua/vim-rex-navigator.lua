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

function M.focus(dir)
  local win = vim.api.nvim_get_current_win()
  vim.cmd('wincmd ' .. WINCMD[dir])
  if win == vim.api.nvim_get_current_win() and vim.env.REX_SESSION then
    vim.system({ 'rex', 'do', 'vim_rex_focus', 'direction=' .. dir })
  end
end

function M.resize(dir, amount)
  amount = amount or 3

  local horizontal = dir == 'left' or dir == 'right'
  local current = vim.fn.winnr()
  local before
  local after

  if horizontal then
    before = vim.fn.winnr('h')
    after = vim.fn.winnr('l')
  else
    before = vim.fn.winnr('k')
    after = vim.fn.winnr('j')
  end

  if before == current and after == current then
    if vim.env.REX_SESSION then vim.system({ 'rex', 'do', 'vim_rex_resize', 'direction=' .. dir }) end
    return
  end

  local grow = dir == 'right' or dir == 'down'
  if after == current then grow = not grow end

  local sign = grow and '+' or '-'
  local command = horizontal and 'vertical resize ' or 'resize '
  vim.cmd(command .. sign .. amount)
end

function M.setup(opts)
  opts = opts or {}

  if opts.focus ~= false then
    vim.keymap.set({ 'n', 't' }, '<M-D-Left>', function() M.focus('left') end)
    vim.keymap.set({ 'n', 't' }, '<M-D-Down>', function() M.focus('down') end)
    vim.keymap.set({ 'n', 't' }, '<M-D-Up>', function() M.focus('up') end)
    vim.keymap.set({ 'n', 't' }, '<M-D-Right>', function() M.focus('right') end)
  end

  if opts.move ~= false then
    vim.keymap.set({ 'n', 't' }, '<S-M-D-Left>', function() M.move('left') end)
    vim.keymap.set({ 'n', 't' }, '<S-M-D-Down>', function() M.move('down') end)
    vim.keymap.set({ 'n', 't' }, '<S-M-D-Up>', function() M.move('up') end)
    vim.keymap.set({ 'n', 't' }, '<S-M-D-Right>', function() M.move('right') end)
  end

  if opts.resize ~= false then
    vim.keymap.set({ 'n', 't' }, '<C-M-D-Left>', function() M.resize('left') end)
    vim.keymap.set({ 'n', 't' }, '<C-M-D-Down>', function() M.resize('down') end)
    vim.keymap.set({ 'n', 't' }, '<C-M-D-Up>', function() M.resize('up') end)
    vim.keymap.set({ 'n', 't' }, '<C-M-D-Right>', function() M.resize('right') end)
  end

  if opts.close ~= false then vim.keymap.set({ 'n', 't' }, '<D-w>', '<cmd>confirm quit<cr>') end
end

return M
