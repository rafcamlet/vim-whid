if exists('g:loaded_whid')
    finish
endif

let g:loaded_whid = 1

command! Whid call whid#start()
