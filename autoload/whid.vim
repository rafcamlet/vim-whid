function! whid#start()
  let s:current_num = 0

  if s:is_whid_open()
    call s:focus()
  else
    call s:open_win()
  endif

  call whid#show(0)
endfunction

function! s:is_whid_open()
  return exists('s:whid_buf') && -1 < bufwinnr(s:whid_buf)
endfunction


function! s:focus()
  exec bufwinnr(s:whid_buf) . 'wincmd w'
endfunction

function! s:open_win()
  let s:buf_name = fnameescape('What have i done?!')
  let s:start_buf = bufnr('%')
  silent execute 'vnew ' . s:buf_name
  let s:whid_buf = bufnr('%')

  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  setlocal nobuflisted
  setlocal nomodeline
  setlocal nomodifiable
  setlocal cursorline

  nnoremap <silent><buffer><nowait> <cr> :call whid#enter()<cr>
  nnoremap <silent><buffer><nowait> p :call whid#preview()<cr>

  nnoremap <silent><buffer><nowait> s :call whid#enter('s')<cr>
  nnoremap <silent><buffer><nowait> i :call whid#enter('i')<cr>
  nnoremap <silent><buffer><nowait> t :call whid#enter('t')<cr>


  nnoremap <silent><buffer><nowait> ] :call whid#show(1)<cr>
  nnoremap <silent><buffer><nowait> [ :call whid#show(-1)<cr>

  nnoremap <silent><buffer> q :q<cr>


  augroup whid_group
    autocmd!

    exec 'autocmd BufEnter ' . s:buf_name . ' setlocal cursorline'
  augroup END

endfunction

function! whid#preview()
  let l:file_name = getline('.')
  exec bufwinnr(s:start_buf) . 'wincmd w'
  exec 'edit ' . l:file_name
  wincmd p
endfunction

fun whid#enter(...)
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

function whid#update(str)
  setlocal modifiable
  normal! ggdG

  call append(0, 'HEAD~' . s:current_num)
  call append(0, 'What have i done?!')
  call append('$', split(a:str, '\v\n'))
  setlocal nomodifiable
endfunction

function whid#show(direction)
  let s:current_num += a:direction
  if s:current_num < 0 | let s:current_num = 0 | endif
  let l:results = system('git diff HEAD~' . s:current_num . ' --name-only')
  call whid#update(l:results)
endfunction
