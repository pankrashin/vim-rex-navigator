local M = {}

local VIM = { vi = true, vim = true, nvim = true, view = true }

local function is_vim(block_id)
  local p = rex.block.call('com.superlogical.terminal', 'process', { block_id = block_id })
  return p ~= nil and p.foreground ~= nil and VIM[p.foreground.name] == true
end

local function move(ctx, dir)
  if is_vim(ctx.block_id) then return false end
  rex.session.focus_direction({ direction = dir, wrap = false })
  return true
end

function M.setup(keys)
  rex.bind(keys.left, function(ctx) return move(ctx, 'left') end)
  rex.bind(keys.right, function(ctx) return move(ctx, 'right') end)
  rex.bind(keys.up, function(ctx) return move(ctx, 'up') end)
  rex.bind(keys.down, function(ctx) return move(ctx, 'down') end)

  rex.action({
    name = 'nav_focus',
    title = 'Navigate: Focus Neighbouring Pane',
    args = { direction = 'string' },
    run = function(ctx, args) rex.session.focus_direction({ direction = args.direction, wrap = false }) end,
  })
end

return M
