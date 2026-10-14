if has('nvim') || exists('g:loaded_vim_rex_navigator') || !has('patch-8.2.1978')
  finish
endif
let g:loaded_vim_rex_navigator = 1

let s:wincmd = {'left': 'h', 'down': 'j', 'up': 'k', 'right': 'l'}

function! s:navigate(dir) abort
  let l:win = win_getid()
  execute 'wincmd' s:wincmd[a:dir]
  if l:win == win_getid() && !empty($REX_SESSION)
    let l:cmd = ['rex', 'do', 'vim_rex_focus', 'direction=' . a:dir]
    if has('job')
      call job_start(l:cmd, {'in_io': 'null', 'out_io': 'null', 'err_io': 'null'})
    else
      call system(join(map(copy(l:cmd), 'shellescape(v:val)')))
    endif
  endif
endfunction

command! RexNavigateLeft  call s:navigate('left')
command! RexNavigateDown  call s:navigate('down')
command! RexNavigateUp    call s:navigate('up')
command! RexNavigateRight call s:navigate('right')

" vim reports cmd as <T-…>, macvim as <D-…>
if get(g:, 'rex_navigator_close', 1)
  nnoremap <silent> <T-w> <Cmd>confirm quit<CR>
  nnoremap <silent> <D-w> <Cmd>confirm quit<CR>
  if has('terminal')
    tnoremap <silent> <T-w> <Cmd>confirm quit<CR>
    tnoremap <silent> <D-w> <Cmd>confirm quit<CR>
  endif
endif

if get(g:, 'rex_navigator_mappings', 1)
  nnoremap <silent> <M-T-Left>  <Cmd>RexNavigateLeft<CR>
  nnoremap <silent> <M-T-Down>  <Cmd>RexNavigateDown<CR>
  nnoremap <silent> <M-T-Up>    <Cmd>RexNavigateUp<CR>
  nnoremap <silent> <M-T-Right> <Cmd>RexNavigateRight<CR>
  nnoremap <silent> <M-D-Left>  <Cmd>RexNavigateLeft<CR>
  nnoremap <silent> <M-D-Down>  <Cmd>RexNavigateDown<CR>
  nnoremap <silent> <M-D-Up>    <Cmd>RexNavigateUp<CR>
  nnoremap <silent> <M-D-Right> <Cmd>RexNavigateRight<CR>
  if has('terminal')
    tnoremap <silent> <M-T-Left>  <Cmd>RexNavigateLeft<CR>
    tnoremap <silent> <M-T-Down>  <Cmd>RexNavigateDown<CR>
    tnoremap <silent> <M-T-Up>    <Cmd>RexNavigateUp<CR>
    tnoremap <silent> <M-T-Right> <Cmd>RexNavigateRight<CR>
    tnoremap <silent> <M-D-Left>  <Cmd>RexNavigateLeft<CR>
    tnoremap <silent> <M-D-Down>  <Cmd>RexNavigateDown<CR>
    tnoremap <silent> <M-D-Up>    <Cmd>RexNavigateUp<CR>
    tnoremap <silent> <M-D-Right> <Cmd>RexNavigateRight<CR>
  endif
endif
