local M = {}

local VIM = { vi = true, vim = true, nvim = true, view = true }

local function is_vim(block_id)
  local p = rex.block.call("com.superlogical.terminal", "process", { block_id = block_id })
  return p ~= nil and p.foreground ~= nil and VIM[p.foreground.name] == true
end

local function at_edge(block_id, dir)
  local view = rex.session.view{}
  for _, layer in ipairs(view.focused_window.layers) do
    for _, b in ipairs(layer.blocks) do
      if b.block_id == block_id then
        local rect = b.rect
        if dir == "left"  then return rect.x <= 0.001 end
        if dir == "up"    then return rect.y <= 0.001 end
        if dir == "right" then return rect.x + rect.w >= 0.999 end
        if dir == "down"  then return rect.y + rect.h >= 0.999 end
      end
    end
  end
  return true
end

local function move(ctx, dir)
  if is_vim(ctx.block_id) then return false end
  if not at_edge(ctx.block_id, dir) then
    rex.session.focus_direction{ direction = dir }
  end
  return true
end

function M.setup(keys)
  keys = keys or {}
  rex.bind(keys.left  or "cmd+alt+left",  function(ctx) return move(ctx, "left")  end)
  rex.bind(keys.right or "cmd+alt+right", function(ctx) return move(ctx, "right") end)
  rex.bind(keys.up    or "cmd+alt+up",    function(ctx) return move(ctx, "up")    end)
  rex.bind(keys.down  or "cmd+alt+down",  function(ctx) return move(ctx, "down")  end)

  rex.action{
    name  = "nav_focus",
    title = "Navigate: Focus Neighbouring Pane",
    args  = { direction = "string" },
    run   = function(ctx, args)
      if not at_edge(ctx.block_id, args.direction) then
        rex.session.focus_direction{ direction = args.direction }
      end
    end,
  }
end

return M
