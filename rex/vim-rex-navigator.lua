local M = {}

local VIM = { vi = true, vim = true, nvim = true, view = true }

local function is_vim(block_id)
  local p = rex.block.call('com.superlogical.terminal', 'process', { block_id = block_id })
  return p ~= nil and p.foreground ~= nil and VIM[p.foreground.name] == true
end

local function move(ctx, dir, wrap)
  if is_vim(ctx.block_id) then return false end
  rex.session.focus_direction({ direction = dir, wrap = wrap })
  return true
end

function M.setup(opts)
  opts = opts or {}
  local wrap = opts.wrap == true

  rex.unbind('alt+cmd+left', 'pane.focus.left')
  rex.unbind('alt+cmd+right', 'pane.focus.right')
  rex.unbind('alt+cmd+up', 'pane.focus.up')
  rex.unbind('alt+cmd+down', 'pane.focus.down')

  rex.bind(opts.left or 'alt+cmd+left', function(ctx) return move(ctx, 'left', wrap) end)
  rex.bind(opts.right or 'alt+cmd+right', function(ctx) return move(ctx, 'right', wrap) end)
  rex.bind(opts.up or 'alt+cmd+up', function(ctx) return move(ctx, 'up', wrap) end)
  rex.bind(opts.down or 'alt+cmd+down', function(ctx) return move(ctx, 'down', wrap) end)

  rex.action({
    name = 'nav_focus',
    title = 'Navigate: Focus Neighbouring Pane',
    args = { direction = 'string' },
    run = function(ctx, args) rex.session.focus_direction({ direction = args.direction, wrap = wrap }) end,
  })
end

return M
