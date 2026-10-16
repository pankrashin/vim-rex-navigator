if vim.g.loaded_vim_rex_navigator then return end
vim.g.loaded_vim_rex_navigator = true

local nav = require('vim-rex-navigator')

vim.api.nvim_create_user_command('RexFocusLeft', function() nav.focus('left') end, {})
vim.api.nvim_create_user_command('RexFocusDown', function() nav.focus('down') end, {})
vim.api.nvim_create_user_command('RexFocusUp', function() nav.focus('up') end, {})
vim.api.nvim_create_user_command('RexFocusRight', function() nav.focus('right') end, {})

vim.api.nvim_create_user_command('RexMoveLeft', function() nav.move('left') end, {})
vim.api.nvim_create_user_command('RexMoveDown', function() nav.move('down') end, {})
vim.api.nvim_create_user_command('RexMoveUp', function() nav.move('up') end, {})
vim.api.nvim_create_user_command('RexMoveRight', function() nav.move('right') end, {})

vim.api.nvim_create_user_command('RexResizeLeft', function() nav.resize('left') end, {})
vim.api.nvim_create_user_command('RexResizeDown', function() nav.resize('down') end, {})
vim.api.nvim_create_user_command('RexResizeUp', function() nav.resize('up') end, {})
vim.api.nvim_create_user_command('RexResizeRight', function() nav.resize('right') end, {})
