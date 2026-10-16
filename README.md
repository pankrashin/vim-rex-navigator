# Vim Rex Navigator

Focus, move, resize and close Vim windows and [Rex](https://www.superlogical.com/rex) panes seamlessly with the same key bindings, in the spirit of [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator).

> [!IMPORTANT]
> Rex is currently in beta and new updates may introduce breaking changes. I’m committed to updating the plugin as quickly as possible when that happens.

## Usage

By default this plugin utilizes the default Rex key bindings wherever it is possible:

### Focus 

- ⌥⌘ ◀ → Left
- ⌥⌘ ▼ → Down
- ⌥⌘ ▲ → Up
- ⌥⌘ ▶ → Right

### Move

- ⇧⌥⌘ ◀ → Left
- ⇧⌥⌘ ▼ → Down
- ⇧⌥⌘ ▲ → Up
- ⇧⌥⌘ ▶ → Right

### Resize

- ⌃⌥⌘ ◀ → Left
- ⌃⌥⌘ ▼ → Down
- ⌃⌥⌘ ▲ → Up
- ⌃⌥⌘ ▶ → Right

### Close

- ⌘W

If you want to use alternate key bindings, see the [key bindings configuration](#keymaps) section below.

## Installation

### Neovim

With `vim.pack` (Neovim 0.12+):

```lua
vim.pack.add { "https://github.com/pankrashin/vim-rex-navigator" }
require("vim-rex-navigator").setup {}
```

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
 { "pankrashin/vim-rex-navigator", main = "vim-rex-navigator", opts = {} }
```

### Vim

Requires Vim 8.2.1978 or newer. With [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'pankrashin/vim-rex-navigator'
```

There is no `setup` call in Vim, the default keymaps are active as soon as the plugin loads.

### Rex

Add to `~/.config/rex/init.lua`, pointing `package.path` at the `rex/` directory of the copy your plugin manager installed.

With `vim.pack`:

```lua
package.path = os.getenv("HOME")
  .. "/.local/share/nvim/site/pack/core/opt/vim-rex-navigator/rex/?.lua;"
  .. package.path

require("vim-rex-navigator").setup()
```

With lazy.nvim:

```lua
package.path = os.getenv("HOME")
  .. "/.local/share/nvim/lazy/vim-rex-navigator/rex/?.lua;"
  .. package.path

require("vim-rex-navigator").setup()
```

With vim-plug:

```lua
package.path = os.getenv("HOME")
  .. "/.vim/plugged/vim-rex-navigator/rex/?.lua;"
  .. package.path

require("vim-rex-navigator").setup()
```

The paths above are the defaults. If you set `$XDG_DATA_HOME` or changed where your plugin manager installs plugins, adjust them to match.

Without a plugin manager, clone the repository anywhere and point `package.path` at its `rex/` directory:

```sh
git clone https://github.com/pankrashin/vim-rex-navigator ~/src/vim-rex-navigator
```

```lua
package.path = os.getenv("HOME")
  .. "/src/vim-rex-navigator/rex/?.lua;"
  .. package.path

require("vim-rex-navigator").setup()
```

Or symlink the file next to your configuration, which needs no `package.path`:

```sh
ln -s ~/src/vim-rex-navigator/rex/vim-rex-navigator.lua ~/.config/rex/vim-rex-navigator.lua
```

```lua
require("vim-rex-navigator").setup()
```

Then reload the configuration:

```sh
rex config check
rex config reload
```

## Configuration

### Keymaps

#### Rex

On the Rex side, pass the keys to `setup`. Any key you leave out keeps its default:

```lua
require("vim-rex-navigator").setup {
  focus_left   = "ctrl+h",
  focus_down   = "ctrl+j",
  focus_up     = "ctrl+k",
  focus_right  = "ctrl+l",

  move_left    = "ctrl+shift+h",
  move_down    = "ctrl+shift+j",
  move_up      = "ctrl+shift+k",
  move_right   = "ctrl+shift+l",

  resize_left  = "ctrl+alt+h",
  resize_down  = "ctrl+alt+j",
  resize_up    = "ctrl+alt+k",
  resize_right = "ctrl+alt+l",

  close        = "alt+w",
}
```

   `focus`, `move`, `resize` and `close` set to `false` each turn off their own key bindings:

   ```lua
   require("vim-rex-navigator").setup {
     focus  = false,
     move   = false,
     resize = false,
     close  = false,
   }
   ```

Rex then keeps its own behavior for those keys.

#### Neovim

On the Neovim side, turn off the default bindings and map them yourself. `focus`, `move`, `resize` and `close` each turn off their own bindings:

```lua
require("vim-rex-navigator").setup { 
  focus = false,
  move = false,
  resize = false,
  close = false }

vim.keymap.set({ "n", "t" }, "<C-h>", "<cmd>RexFocusLeft<cr>")
vim.keymap.set({ "n", "t" }, "<C-j>", "<cmd>RexFocusDown<cr>")
vim.keymap.set({ "n", "t" }, "<C-k>", "<cmd>RexFocusUp<cr>")
vim.keymap.set({ "n", "t" }, "<C-l>", "<cmd>RexFocusRight<cr>")

vim.keymap.set({ "n", "t" }, "<C-S-h>", "<cmd>RexMoveLeft<cr>")
vim.keymap.set({ "n", "t" }, "<C-S-j>", "<cmd>RexMoveDown<cr>")
vim.keymap.set({ "n", "t" }, "<C-S-k>", "<cmd>RexMoveUp<cr>")
vim.keymap.set({ "n", "t" }, "<C-S-l>", "<cmd>RexMoveRight<cr>")

vim.keymap.set({ "n", "t" }, "<C-M-h>", "<cmd>RexResizeLeft<cr>")
vim.keymap.set({ "n", "t" }, "<C-M-j>", "<cmd>RexResizeDown<cr>")
vim.keymap.set({ "n", "t" }, "<C-M-k>", "<cmd>RexResizeUp<cr>")
vim.keymap.set({ "n", "t" }, "<C-M-l>", "<cmd>RexResizeRight<cr>")

vim.keymap.set({ "n", "t" }, "<M-w>", "<cmd>confirm quit<cr>")
```

#### Vim

On the Vim side, do the same in your `vimrc`. `g:vim_rex_navigator_focus`, `g:vim_rex_navigator_move`, `g:vim_rex_navigator_resize` and `g:vim_rex_navigator_close` set to `0` each turn off their own bindings:

```vim
let g:vim_rex_navigator_focus = 0
let g:vim_rex_navigator_move = 0
let g:vim_rex_navigator_resize = 0
let g:vim_rex_navigator_close = 0

nnoremap <silent> <C-h> <Cmd>RexFocusLeft<CR>
nnoremap <silent> <C-j> <Cmd>RexFocusDown<CR>
nnoremap <silent> <C-k> <Cmd>RexFocusUp<CR>
nnoremap <silent> <C-l> <Cmd>RexFocusRight<CR>

nnoremap <silent> <C-S-h> <Cmd>RexMoveLeft<CR>
nnoremap <silent> <C-S-j> <Cmd>RexMoveDown<CR>
nnoremap <silent> <C-S-k> <Cmd>RexMoveUp<CR>
nnoremap <silent> <C-S-l> <Cmd>RexMoveRight<CR>

nnoremap <silent> <C-M-h> <Cmd>RexResizeLeft<CR>
nnoremap <silent> <C-M-j> <Cmd>RexResizeDown<CR>
nnoremap <silent> <C-M-k> <Cmd>RexResizeUp<CR>
nnoremap <silent> <C-M-l> <Cmd>RexResizeRight<CR>

nnoremap <silent> <M-w> <Cmd>confirm quit<CR>
```

For terminal windows, add the same bindings with `tnoremap`.

Neovim writes ⌘ as `<D-…>`, but Vim writes it as `<T-…>`. For example, ⌥⌘◀ is `<M-D-Left>` in Neovim and `<M-T-Left>` in Vim, and ⌘W is `<D-w>` in Neovim and `<T-w>` in Vim.

The keys must match on both sides. They must also not be bound to anything else in your Rex configuration, otherwise Rex handles them before they reach Vim or Neovim.

### Wrapping

By default, focus stops at the edge of the window. To wrap around to the pane on the opposite side, set `focus_wrap` in the Rex `setup`:

```lua
require("vim-rex-navigator").setup { focus_wrap = true }
```

Wrapping applies to Rex panes only, Vim windows do not wrap.

### Resize Step

Rex panes are resized by 5% of the split per key press. To change that, set `resize_amount` in the Rex `setup`:

```lua
require("vim-rex-navigator").setup { resize_amount = 10 }
```

Vim windows are resized by 3 cells per key press.

## Known Problems

### Fish prompt is duplicated when resizing

In [fish](https://fishshell.com), resizing a Rex pane can leave copies of the prompt behind, such as `user@host ~/…r…ok-pro user@host ~/.c/rex>`. Every resize adds more of them.

This is not specific to this plugin and also happens when resizing panes with the mouse or resizing the window. Rex reflows the text on the screen when a pane changes width, and fish redraws its prompt at the same time. fish only skips the redraw in terminals it knows reflow on their own, and Rex is not one of them yet.

To fix it, tell fish that Rex reflows by adding this to `~/.config/fish/config.fish`:

```fish
if test "$TERM_PROGRAM" = rex
    set -g fish_handle_reflow 0
end
```
