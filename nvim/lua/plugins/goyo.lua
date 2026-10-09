return {
    'https://github.com/junegunn/goyo.vim',
    cmd = { 'MarkdownWrap', 'Goyo' },
    config = function()
        vim.api.nvim_create_user_command('MarkdownWrap', function()
            if vim.t.goyo_dim then
                vim.cmd('Goyo!')
                return
            end
            if vim.bo.filetype ~= 'markdown' then
                vim.notify('MarkdownWrap is only available for Markdown buffers')
                return
            end

            vim.cmd('Goyo 80')
            vim.t.markdown_wrap_active = true
            vim.opt_local.wrap = true
            vim.opt_local.linebreak = true
            vim.opt_local.breakindent = true
            vim.opt_local.signcolumn = 'no'
            vim.opt_local.foldcolumn = '0'
            vim.cmd('vertical resize 80')

            vim.api.nvim_create_autocmd('VimResized', {
                group = vim.api.nvim_create_augroup('markdown-wrap-resize', { clear = true }),
                callback = function()
                    if vim.t.markdown_wrap_active and vim.bo.filetype == 'markdown' then
                        vim.cmd('vertical resize 80')
                    end
                end,
            })
        end, { desc = 'Toggle an 80-column soft-wrapped Markdown pane' })

        vim.api.nvim_create_autocmd({ 'BufEnter', 'FileType' }, {
            group = vim.api.nvim_create_augroup('markdown-wrap-exit', { clear = true }),
            -- Wait for filetype detection and Goyo's temporary window changes.
            callback = vim.schedule_wrap(function()
                local target = vim.api.nvim_get_current_buf()
                if not vim.t.markdown_wrap_active or vim.bo.filetype == 'markdown'
                    or vim.tbl_contains(vim.t.goyo_pads or {}, target) then
                    return
                end
                vim.cmd('Goyo!')
                vim.cmd('keepalt buffer ' .. target)
                vim.opt_local.wrap = false
            end),
        })
    end,
}
