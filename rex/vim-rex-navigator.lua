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

local function close(ctx)
  if is_vim(ctx.block_id) then return false end
  rex.call('block.close', { session_id = ctx.session_id, block_id = ctx.block_id })
  return true
end

function M.setup(opts)
  opts = opts or {}
  local wrap = opts.wrap == true

  local close_key = opts.close
  if close_key == nil or close_key == true then close_key = 'cmd+w' end
  if close_key then rex.bind(close_key, close) end

  rex.unbind('opt+cmd+left', 'pane.focus.left')
  rex.unbind('opt+cmd+right', 'pane.focus.right')
  rex.unbind('opt+cmd+up', 'pane.focus.up')
  rex.unbind('opt+cmd+down', 'pane.focus.down')

  rex.bind(opts.left or 'opt+cmd+left', function(ctx) return move(ctx, 'left', wrap) end)
  rex.bind(opts.right or 'opt+cmd+right', function(ctx) return move(ctx, 'right', wrap) end)
  rex.bind(opts.up or 'opt+cmd+up', function(ctx) return move(ctx, 'up', wrap) end)
  rex.bind(opts.down or 'opt+cmd+down', function(ctx) return move(ctx, 'down', wrap) end)

  -- this action is called from vim
  rex.action({
    name = 'vim_rex_focus',
    title = 'Focus Neighbouring Rex Pane',
    args = { direction = 'string' },
    run = function(ctx, args) rex.session.focus_direction({ direction = args.direction, wrap = wrap }) end,
  })
end

return M
