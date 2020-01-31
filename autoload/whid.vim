function! whid#start()
  let s:current_num = 0

  if s:is_whid_open()
    call s:focus()
  else
    call s:open_win()
  endif

  call s:show(0)
endfunction

function! s:is_whid_open()
  return exists('s:whid_buf') && -1 < bufwinnr(s:whid_buf)
endfunction

function! s:focus()
  exec bufwinnr(s:whid_buf) . 'wincmd w'
endfunction

function! s:maps()
  nnoremap <silent> <buffer> <nowait> <cr> :call <sid>enter()<cr>
  nnoremap <silent> <buffer> <nowait> p :call <sid>preview()<cr>

  nnoremap <silent> <buffer> <nowait> s :call <sid>enter('s')<cr>
  nnoremap <silent> <buffer> <nowait> i :call <sid>enter('i')<cr>
  nnoremap <silent> <buffer> <nowait> t :call <sid>enter('t')<cr>

  nnoremap <silent> <buffer> <nowait> ] :call <sid>show(1)<cr>
  nnoremap <silent> <buffer> <nowait> [ :call <sid>show(-1)<cr>

  nnoremap <silent> <buffer> q :q<cr>
endfunction

function! s:set_locals()
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  setlocal nobuflisted
  setlocal nomodeline
  setlocal nomodifiable
  setlocal cursorline
endfunction

function! s:syntax()
  setf WHID
  syn clear
  syn match whidHeader     /\%1l.*/
  syn match whidSubHeader  /\%2l.*/
  syn match whidFilelist   /\%>2l.*/

  hi def link whidHeader      Number
  hi def link whidSubHeader   Identifier
  hi def link whidFilelist    Statement
endfunction

function! s:open_win()
  let s:buf_name = fnameescape('What have i done?!')
  let s:start_buf = bufnr('%')
  silent execute 'vnew ' . s:buf_name
  let s:whid_buf = bufnr('%')

  call s:set_locals()
  call s:maps()
  call s:syntax()

  augroup whid_group
    autocmd!
    exec 'autocmd BufEnter ' . s:buf_name . ' setlocal cursorline'
  augroup END
endfunction

function! s:preview()
  let l:file_name = getline('.')
  exec bufwinnr(s:start_buf) . 'wincmd w'
  exec 'edit ' . l:file_name
  wincmd p
endfunction

function! s:enter(...)
  let l:file_name = getline('.')

  wincmd q

  if bufnr('%') != s:start_buf
    exec bufwinnr(s:start_buf) . 'wincmd w'
  endif

  if a:0 == 0
    let l:open_method = 'edit '
  elseif a:1 ==# 's'
    let l:open_method = 'vnew '
  elseif a:1 ==# 'i'
    let l:open_method = 'split '
  elseif a:1 ==# 't'
    let l:open_method = 'tabedit '
  end
  exec  l:open_method . l:file_name
endf

function! s:update(str)
  setlocal modifiable
  normal! gg"_dG

  call append(0, [
        \ 'What have i done?!',
        \ 'HEAD~' . s:current_num
        \])

  call append('$', split(a:str, '\v\n'))
  setlocal nomodifiable
endfunction

function! s:show(direction)
  let s:current_num += a:direction
  if s:current_num < 0 | let s:current_num = 0 | endif
  let l:results = system('git diff HEAD~' . s:current_num . ' --name-only')
  call s:update(l:results)
endfunction
