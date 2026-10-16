local M = {}

local VIM = { vim = true, nvim = true }
local DIRECTIONS = { left = true, right = true, up = true, down = true }
local AXIS = { left = 'horizontal', right = 'horizontal', up = 'vertical', down = 'vertical' }
local STEP = { left = -1, right = 1, up = -1, down = 1 }

local function is_vim(block_id)
  local p = rex.block.call('com.superlogical.terminal', 'process', { block_id = block_id })
  return p ~= nil and p.foreground ~= nil and VIM[p.foreground.name] == true
end

local function active_window()
  local view = rex.session.view({})

  for _, window in ipairs(view.windows) do
    if window.window_id == view.active_window_id then return window end
  end
end

local function panes_of(window, block_id)
  for _, layer in ipairs(window.layers) do
    local panes = {}
    local src = nil

    local function walk(node)
      if node.block_id then
        local x, y, w, h = node.rect[1], node.rect[2], node.rect[3], node.rect[4]
        local pane = { id = node.block_id, min_x = x, min_y = y, max_x = x + w, max_y = y + h }
        panes[#panes + 1] = pane

        if pane.id == block_id then src = pane end
      else
        walk(node.split.before)
        walk(node.split.after)
      end
    end

    walk(layer.layout)

    if src then return panes, src end
  end
end

local function neighboring_pane(panes, src, direction)
  local best, best_overlaps, best_distance, best_gap

  for _, pane in ipairs(panes) do
    local empty = pane.max_x <= pane.min_x or pane.max_y <= pane.min_y

    if pane ~= src and not empty then
      local beyond, distance

      if direction == 'left' then
        beyond = pane.max_x <= src.min_x + 1e-6
        distance = src.min_x - pane.max_x
      elseif direction == 'right' then
        beyond = pane.min_x >= src.max_x - 1e-6
        distance = pane.min_x - src.max_x
      elseif direction == 'up' then
        beyond = pane.max_y <= src.min_y + 1e-6
        distance = src.min_y - pane.max_y
      else
        beyond = pane.min_y >= src.max_y - 1e-6
        distance = pane.min_y - src.max_y
      end

      if beyond then
        local lo, hi, src_lo, src_hi

        if direction == 'left' or direction == 'right' then
          lo = pane.min_y
          hi = pane.max_y
          src_lo = src.min_y
          src_hi = src.max_y
        else
          lo = pane.min_x
          hi = pane.max_x
          src_lo = src.min_x
          src_hi = src.max_x
        end

        local overlaps = math.max(math.min(hi, src_hi) - math.max(lo, src_lo), 0) > 1e-6
        local gap = math.max(math.max(lo, src_lo) - math.min(hi, src_hi), 0)
        distance = math.max(distance, 0)

        local better

        if best == nil then
          better = true
        elseif overlaps ~= best_overlaps then
          better = overlaps
        elseif distance < best_distance - 1e-6 then
          better = true
        else
          better = math.abs(distance - best_distance) <= 1e-6 and gap < best_gap - 1e-6
        end

        if better then
          best = pane
          best_overlaps = overlaps
          best_distance = distance
          best_gap = gap
        end
      end
    end
  end

  return best and best.id
end

local function swap_blocks(dir)
  if not DIRECTIONS[dir] then return end

  local window = active_window()
  if window == nil or window.zoomed_block_id then return end

  local panes, from = panes_of(window, window.focused_block_id)
  if not from then return true end

  local to = neighboring_pane(panes, from, dir)
  if to then rex.session.swap_blocks({ block_id = from.id, other_block_id = to }) end

  return true
end

local function move(ctx, dir)
  if is_vim(ctx.block_id) then return false end
  return swap_blocks(dir)
end

local function focus(ctx, dir, wrap)
  if is_vim(ctx.block_id) then return false end
  if not DIRECTIONS[dir] then return end

  local window = active_window()
  if window == nil or window.zoomed_block_id then return end

  rex.session.focus_direction({ direction = dir, wrap = wrap })
  return true
end

local function first_block(node)
  if node.block_id then return node.block_id end
  return first_block(node.split.before)
end

local function divider(node, block_id, axis, nearest)
  if node.block_id then
    if node.block_id == block_id then return nearest end
    return nil
  end

  local split = node.split
  if split.direction == axis then nearest = split end

  local found = divider(split.before, block_id, axis, nearest)
  if found then return found end

  return divider(split.after, block_id, axis, nearest)
end

local function resize_split(dir, amount)
  if not DIRECTIONS[dir] then return end

  local window = active_window()
  if window == nil or window.zoomed_block_id then return end

  local split = nil

  for _, layer in ipairs(window.layers) do
    if split == nil and layer.layout ~= nil then
      split = divider(layer.layout, window.focused_block_id, AXIS[dir], nil)
    end
  end

  if split == nil then return true end

  local min_ratio = 0.05
  local ratio = split.ratio + STEP[dir] * amount / 100
  ratio = math.min(ratio, 1 - min_ratio)
  ratio = math.max(ratio, min_ratio)

  rex.session.resize_pane({
    direction = split.direction,
    before_block_id = first_block(split.before),
    after_block_id = first_block(split.after),
    ratio = ratio,
  })

  return true
end

local function resize(ctx, dir, amount)
  if is_vim(ctx.block_id) then return false end
  return resize_split(dir, amount)
end

local function close(ctx)
  if is_vim(ctx.block_id) then return false end
  rex.call('block.close', { session_id = ctx.session_id, block_id = ctx.block_id })
  return true
end

function M.setup(opts)
  opts = opts or {}

  local focus_wrap = opts.focus_wrap == true
  local resize_amount = opts.resize_amount or 5
  local close_key = (opts.close == nil or opts.close == true) and 'cmd+w' or opts.close

  if opts.focus ~= false then
    rex.unbind('opt+cmd+left', 'pane.focus.left')
    rex.unbind('opt+cmd+down', 'pane.focus.down')
    rex.unbind('opt+cmd+up', 'pane.focus.up')
    rex.unbind('opt+cmd+right', 'pane.focus.right')

    rex.bind(opts.focus_left or 'opt+cmd+left', function(ctx) return focus(ctx, 'left', focus_wrap) end)
    rex.bind(opts.focus_down or 'opt+cmd+down', function(ctx) return focus(ctx, 'down', focus_wrap) end)
    rex.bind(opts.focus_up or 'opt+cmd+up', function(ctx) return focus(ctx, 'up', focus_wrap) end)
    rex.bind(opts.focus_right or 'opt+cmd+right', function(ctx) return focus(ctx, 'right', focus_wrap) end)
  end

  if opts.move ~= false then
    rex.unbind('shift+opt+cmd+left', 'pane.move.left')
    rex.unbind('shift+opt+cmd+down', 'pane.move.down')
    rex.unbind('shift+opt+cmd+up', 'pane.move.up')
    rex.unbind('shift+opt+cmd+right', 'pane.move.right')

    rex.bind(opts.move_left or 'shift+opt+cmd+left', function(ctx) return move(ctx, 'left') end)
    rex.bind(opts.move_down or 'shift+opt+cmd+down', function(ctx) return move(ctx, 'down') end)
    rex.bind(opts.move_up or 'shift+opt+cmd+up', function(ctx) return move(ctx, 'up') end)
    rex.bind(opts.move_right or 'shift+opt+cmd+right', function(ctx) return move(ctx, 'right') end)
  end

  if opts.resize ~= false then
    rex.bind(opts.resize_left or 'ctrl+opt+cmd+left', function(ctx) return resize(ctx, 'left', resize_amount) end)
    rex.bind(opts.resize_down or 'ctrl+opt+cmd+down', function(ctx) return resize(ctx, 'down', resize_amount) end)
    rex.bind(opts.resize_up or 'ctrl+opt+cmd+up', function(ctx) return resize(ctx, 'up', resize_amount) end)
    rex.bind(opts.resize_right or 'ctrl+opt+cmd+right', function(ctx) return resize(ctx, 'right', resize_amount) end)
  end

  if close_key then rex.bind(close_key, close) end

  -- these actions are called from (n)vim
  rex.action({
    name = 'vim_rex_focus',
    title = 'Focus Neighbouring Rex Pane',
    args = { direction = 'string' },
    run = function(ctx, args) rex.session.focus_direction({ direction = args.direction, wrap = focus_wrap }) end,
  })

  rex.action({
    name = 'vim_rex_move',
    title = 'Move Rex Pane',
    args = { direction = 'string' },
    run = function(ctx, args) swap_blocks(args.direction) end,
  })

  rex.action({
    name = 'vim_rex_resize',
    title = 'Resize Rex Pane',
    args = { direction = 'string', amount = 'number?' },
    run = function(ctx, args) resize_split(args.direction, args.amount or resize_amount) end,
  })
end

return M
