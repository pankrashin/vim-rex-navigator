# Vim Rex Navigator

Move between Vim windows and [Rex](https://www.superlogical.com/rex) panes with the same keymaps, in the spirit of [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator).

> [!IMPORTANT]
> Rex is currently in beta, expect breaking changes.

## Usage

Default keymaps are:
- ⌘⌥◀ → Left
- ⌘⌥▶ → Right
- ⌘⌥▲ → Up
- ⌘⌥▼ → Down

If you want to use alternate key mappings, see the configuration section below.

## Installation

### Neovim

With `vim.pack` (Neovim 0.12+):

```lua
vim.pack.add { "https://github.com/pankrashin/vim-rex-navigator" }
require("vim-rex-navigator").setup {}
```

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{ "pankrashin/vim-rex-navigator", lazy = false, main = "vim-rex-navigator", opts = {} }
```

### Rex

Add to `~/.config/rex/init.lua`, pointing `package.path` at the `rex/` folder of this repository. With `vim.pack`, that's the copy Neovim installed:

```lua
package.path = os.getenv("HOME")
  .. "/.local/share/nvim/site/pack/core/opt/vim-rex-navigator/rex/?.lua;"
  .. package.path

require("vim-rex-navigator").setup()
```

With lazy.nvim, the path is `~/.local/share/nvim/lazy/vim-rex-navigator/rex/`. You can also clone the repository anywhere and use that path instead, or symlink `rex/vim-rex-navigator.lua` into `~/.config/rex/`.

Then reload the configuration:

```sh
rex config check
rex config reload
```

## Configuration

### Keymaps

On the Rex side, pass the keys to `setup`. Any key you leave out keeps its default:

```lua
require("vim-rex-navigator").setup{
  left  = "ctrl+h",
  down  = "ctrl+j",
  up    = "ctrl+k",
  right = "ctrl+l",
}
```

On the Neovim side, turn off the default mappings and map the commands yourself:

```lua
require("vim-rex-navigator").setup { mappings = false }

vim.keymap.set({ "n", "t" }, "<C-h>", "<cmd>RexNavigateLeft<cr>")
vim.keymap.set({ "n", "t" }, "<C-j>", "<cmd>RexNavigateDown<cr>")
vim.keymap.set({ "n", "t" }, "<C-k>", "<cmd>RexNavigateUp<cr>")
vim.keymap.set({ "n", "t" }, "<C-l>", "<cmd>RexNavigateRight<cr>")
```

The keys must match on both sides.

### Commands

| Command | Moves |
| --- | --- |
| `:RexNavigateLeft` | Left |
| `:RexNavigateDown` | Down |
| `:RexNavigateUp` | Up |
| `:RexNavigateRight` | Right |

The commands are available without calling `setup`. From Lua, the same is `require("vim-rex-navigator").navigate("left")`.

The Rex part also adds the action `nav_focus`, which moves focus away from the pane it is run in without checking for (n)vim:

```sh
rex do nav_focus direction=left
```

## Limitations

- nvim over `ssh` is not detected: the foreground process is `ssh`.
- A zoomed pane can still move focus to a pane hidden behind it.
- A pane started with a script as its command reports the script, not nvim,
  as the foreground process.