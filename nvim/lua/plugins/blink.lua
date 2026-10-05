return {
    'https://github.com/saghen/blink.cmp',
    version = '1.*',
    lazy = false,
    opts = {
        keymap = {
            preset = 'super-tab',
            ['<C-k>'] = false, -- Preserve the existing insert-mode cursor-up mapping.
        },
        fuzzy = { implementation = 'lua' },
    },
}
