if vim.g.loaded_vim_rex_navigator then return end
vim.g.loaded_vim_rex_navigator = true

local nav = require('vim-rex-navigator')

vim.api.nvim_create_user_command('RexNavigateLeft', function() nav.navigate('left') end, {})
vim.api.nvim_create_user_command('RexNavigateDown', function() nav.navigate('down') end, {})
vim.api.nvim_create_user_command('RexNavigateUp', function() nav.navigate('up') end, {})
vim.api.nvim_create_user_command('RexNavigateRight', function() nav.navigate('right') end, {})

vim.api.nvim_create_user_command('RexMoveLeft', function() nav.move('left') end, {})
vim.api.nvim_create_user_command('RexMoveDown', function() nav.move('down') end, {})
vim.api.nvim_create_user_command('RexMoveUp', function() nav.move('up') end, {})
vim.api.nvim_create_user_command('RexMoveRight', function() nav.move('right') end, {})
