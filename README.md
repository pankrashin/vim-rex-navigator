# Vim Rex Navigator

Move between and close Vim windows and [Rex](https://www.superlogical.com/rex) panes with the same keymaps, in the spirit of [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator).

> [!IMPORTANT]
> Rex is currently in beta, expect breaking changes.

## Usage

Default keymaps are:
- ⌥⌘◀ → Left
- ⌥⌘▶ → Right
- ⌥⌘▲ → Up
- ⌥⌘▼ → Down
- ⌘W → Close

In a Rex pane, ⌘W closes the pane. In (n)vim, it closes the current Vim window instead. Closing the last window quits (n)vim, asking first if there are unsaved changes, and pressing ⌘W again then closes the Rex pane.

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

### Vim

Requires Vim 8.2.1978 or newer. With [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'pankrashin/vim-rex-navigator'
```

There is no `setup` call in Vim, the default keymaps are active as soon as the plugin loads.

### Rex

Add to `~/.config/rex/init.lua`, pointing `package.path` at the `rex/` folder of this repository. With `vim.pack`, that's the copy Neovim installed:

```lua
package.path = os.getenv("HOME")
  .. "/.local/share/nvim/site/pack/core/opt/vim-rex-navigator/rex/?.lua;"
  .. package.path

require("vim-rex-navigator").setup()
```

With lazy.nvim, the path is `~/.local/share/nvim/lazy/vim-rex-navigator/rex/`, with vim-plug it is `~/.vim/plugged/vim-rex-navigator/rex/`. You can also clone the repository anywhere and use that path instead, or symlink `rex/vim-rex-navigator.lua` into `~/.config/rex/`.

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
  close = "alt+w",
}
```

On the Neovim side, turn off the default mappings and map them yourself. `mappings = false` turns off the navigation mappings and `close = false` turns off the close mapping:

```lua
require("vim-rex-navigator").setup { mappings = false, close = false }

vim.keymap.set({ "n", "t" }, "<C-h>", "<cmd>RexNavigateLeft<cr>")
vim.keymap.set({ "n", "t" }, "<C-j>", "<cmd>RexNavigateDown<cr>")
vim.keymap.set({ "n", "t" }, "<C-k>", "<cmd>RexNavigateUp<cr>")
vim.keymap.set({ "n", "t" }, "<C-l>", "<cmd>RexNavigateRight<cr>")
vim.keymap.set({ "n", "t" }, "<M-w>", "<cmd>confirm quit<cr>")
```

On the Vim side, do the same in your `vimrc`. `g:rex_navigator_mappings = 0` turns off the navigation mappings and `g:rex_navigator_close = 0` turns off the close mapping:

```vim
let g:rex_navigator_mappings = 0
let g:rex_navigator_close = 0

nnoremap <silent> <C-h> <Cmd>RexNavigateLeft<CR>
nnoremap <silent> <C-j> <Cmd>RexNavigateDown<CR>
nnoremap <silent> <C-k> <Cmd>RexNavigateUp<CR>
nnoremap <silent> <C-l> <Cmd>RexNavigateRight<CR>
nnoremap <silent> <M-w> <Cmd>confirm quit<CR>

tnoremap <silent> <C-h> <Cmd>RexNavigateLeft<CR>
tnoremap <silent> <C-j> <Cmd>RexNavigateDown<CR>
tnoremap <silent> <C-k> <Cmd>RexNavigateUp<CR>
tnoremap <silent> <C-l> <Cmd>RexNavigateRight<CR>
tnoremap <silent> <M-w> <Cmd>confirm quit<CR>
```

Neovim writes ⌘ as `<D-…>`, but terminal Vim writes it as `<T-…>`. For example, ⌥⌘◀ is `<M-D-Left>` in Neovim and `<M-T-Left>` in Vim, and ⌘W is `<D-w>` in Neovim and `<T-w>` in Vim.

The keys must match on both sides. They must also not be bound to anything else in your Rex configuration, otherwise Rex handles them before they reach (n)vim.

### Closing

To turn off closing keymaps, set `close` to `false` on both sides. Rex then keeps its own behaviour for ⌘W, and Vim gets no close mapping:

```lua
-- Rex
require("vim-rex-navigator").setup { close = false }

-- Neovim
require("vim-rex-navigator").setup { close = false }
```

```vim
" Vim
let g:rex_navigator_close = 0
```

### Wrapping

By default, focus stops at the edge of the window. To wrap around to the pane on the opposite side, set `wrap` in the Rex `setup`:

```lua
require("vim-rex-navigator").setup { wrap = true }
```

It can be combined with custom keymaps:

```lua
require("vim-rex-navigator").setup {
  left  = "ctrl+h",
  down  = "ctrl+j",
  up    = "ctrl+k",
  right = "ctrl+l",
  wrap  = true,
}
```

Wrapping applies to Rex panes only, Vim windows do not wrap.

### Commands

| Command | Moves |
| --- | --- |
| `:RexNavigateLeft` | Left |
| `:RexNavigateDown` | Down |
| `:RexNavigateUp` | Up |
| `:RexNavigateRight` | Right |

The commands are available without calling `setup` in Neovim, and as soon as the plugin loads in Vim. From Lua, the same is `require("vim-rex-navigator").navigate("left")`.

The Rex part also adds the action `vim_rex_focus`, which moves focus away from the pane it is run in without checking for (n)vim:

```sh
rex do vim_rex_focus direction=left
```

## Limitations

- nvim over `ssh` is not detected: the foreground process is `ssh`.
- A zoomed pane can still move focus to a pane hidden behind it.
- A pane started with a script as its command reports the script, not nvim,
  as the foreground process.
- When nvim is not detected, as in the cases above, the close key closes the
  whole Rex pane, including any unsaved changes in nvim.