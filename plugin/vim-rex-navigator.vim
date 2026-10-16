if has('nvim') || exists('g:loaded_vim_rex_navigator') || !has('patch-8.2.1978')
  finish
endif
let g:loaded_vim_rex_navigator = 1

let s:wincmd = {'left': 'h', 'down': 'j', 'up': 'k', 'right': 'l'}

function! s:rex_do(action, dir) abort
  if empty($REX_SESSION)
    return
  endif

  let l:cmd = ['rex', 'do', a:action, 'direction=' . a:dir]
  if has('job')
    call job_start(l:cmd, {'in_io': 'null', 'out_io': 'null', 'err_io': 'null'})
  else
    call system(join(map(copy(l:cmd), 'shellescape(v:val)')))
  endif
endfunction

function! s:focus(dir) abort
  let l:win = win_getid()
  execute 'wincmd' s:wincmd[a:dir]
  if l:win == win_getid()
    call s:rex_do('vim_rex_focus', a:dir)
  endif
endfunction

function! s:swap_with(target) abort
  let l:current = win_getid()
  let l:current_buf = winbufnr(l:current)
  let l:target_buf = winbufnr(a:target)
  let l:current_view = winsaveview()

  call win_gotoid(a:target)
  let l:target_view = winsaveview()
  execute 'buffer!' l:current_buf
  call winrestview(l:current_view)

  call win_gotoid(l:current)
  execute 'buffer!' l:target_buf
  call winrestview(l:target_view)

  call win_gotoid(a:target)
endfunction

function! s:move(dir) abort
  let l:current = win_getid()
  let l:target = win_getid(winnr(s:wincmd[a:dir]))
  if l:target != 0 && l:target != l:current
    call s:swap_with(l:target)
  else
    call s:rex_do('vim_rex_move', a:dir)
  endif
endfunction

function! s:resize(dir) abort
  let l:horizontal = a:dir ==# 'left' || a:dir ==# 'right'
  let l:current = winnr()

  if l:horizontal
    let l:before = winnr('h')
    let l:after = winnr('l')
  else
    let l:before = winnr('k')
    let l:after = winnr('j')
  endif

  if l:before == l:current && l:after == l:current
    call s:rex_do('vim_rex_resize', a:dir)
    return
  endif

  let l:grow = a:dir ==# 'right' || a:dir ==# 'down'
  if l:after == l:current
    let l:grow = !l:grow
  endif

  let l:sign = l:grow ? '+' : '-'
  let l:command = l:horizontal ? 'vertical resize ' : 'resize '
  execute l:command . l:sign . 3
endfunction

command! RexFocusLeft  call s:focus('left')
command! RexFocusDown  call s:focus('down')
command! RexFocusUp    call s:focus('up')
command! RexFocusRight call s:focus('right')

command! RexMoveLeft  call s:move('left')
command! RexMoveDown  call s:move('down')
command! RexMoveUp    call s:move('up')
command! RexMoveRight call s:move('right')

command! RexResizeLeft  call s:resize('left')
command! RexResizeDown  call s:resize('down')
command! RexResizeUp    call s:resize('up')
command! RexResizeRight call s:resize('right')

if get(g:, 'vim_rex_navigator_focus', 1)
  nnoremap <silent> <M-T-Left>  <Cmd>RexFocusLeft<CR>
  nnoremap <silent> <M-T-Down>  <Cmd>RexFocusDown<CR>
  nnoremap <silent> <M-T-Up>    <Cmd>RexFocusUp<CR>
  nnoremap <silent> <M-T-Right> <Cmd>RexFocusRight<CR>
  if has('terminal')
    tnoremap <silent> <M-T-Left>  <Cmd>RexFocusLeft<CR>
    tnoremap <silent> <M-T-Down>  <Cmd>RexFocusDown<CR>
    tnoremap <silent> <M-T-Up>    <Cmd>RexFocusUp<CR>
    tnoremap <silent> <M-T-Right> <Cmd>RexFocusRight<CR>
  endif
endif

if get(g:, 'vim_rex_navigator_move', 1)
  nnoremap <silent> <S-M-T-Left>  <Cmd>RexMoveLeft<CR>
  nnoremap <silent> <S-M-T-Down>  <Cmd>RexMoveDown<CR>
  nnoremap <silent> <S-M-T-Up>    <Cmd>RexMoveUp<CR>
  nnoremap <silent> <S-M-T-Right> <Cmd>RexMoveRight<CR>
  if has('terminal')
    tnoremap <silent> <S-M-T-Left>  <Cmd>RexMoveLeft<CR>
    tnoremap <silent> <S-M-T-Down>  <Cmd>RexMoveDown<CR>
    tnoremap <silent> <S-M-T-Up>    <Cmd>RexMoveUp<CR>
    tnoremap <silent> <S-M-T-Right> <Cmd>RexMoveRight<CR>
  endif
endif

if get(g:, 'vim_rex_navigator_resize', 1)
  nnoremap <silent> <C-M-T-Left>  <Cmd>RexResizeLeft<CR>
  nnoremap <silent> <C-M-T-Down>  <Cmd>RexResizeDown<CR>
  nnoremap <silent> <C-M-T-Up>    <Cmd>RexResizeUp<CR>
  nnoremap <silent> <C-M-T-Right> <Cmd>RexResizeRight<CR>
  if has('terminal')
    tnoremap <silent> <C-M-T-Left>  <Cmd>RexResizeLeft<CR>
    tnoremap <silent> <C-M-T-Down>  <Cmd>RexResizeDown<CR>
    tnoremap <silent> <C-M-T-Up>    <Cmd>RexResizeUp<CR>
    tnoremap <silent> <C-M-T-Right> <Cmd>RexResizeRight<CR>
  endif
endif

if get(g:, 'vim_rex_navigator_close', 1)
  nnoremap <silent> <T-w> <Cmd>confirm quit<CR>
  if has('terminal')
    tnoremap <silent> <T-w> <Cmd>confirm quit<CR>
  endif
endif

