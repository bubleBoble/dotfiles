" Toggle an 80-column soft-wrapped Markdown pane without editing the file.
function! s:markdown_wrap()
    if exists('t:goyo_dim')
        Goyo!
        return
    endif
    if &filetype !=# 'markdown'
        echo 'MarkdownWrap is only available for Markdown buffers'
        return
    endif

    Goyo 80
    let t:markdown_wrap_active = 1
    setlocal wrap linebreak breakindent signcolumn=no foldcolumn=0
    vertical resize 80

    augroup markdown_wrap_resize
        autocmd!
        autocmd VimResized * if get(t:, 'markdown_wrap_active', 0) && &filetype ==# 'markdown' | vertical resize 80 | endif
    augroup END
endfunction

command! MarkdownWrap call <SID>markdown_wrap()
