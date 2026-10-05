return {
    'https://github.com/nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
        'https://github.com/nvim-lua/plenary.nvim',
        'https://github.com/MunifTanjim/nui.nvim',
        'https://github.com/nvim-tree/nvim-web-devicons',
        'https://github.com/s1n7ax/nvim-window-picker',
    },
    lazy = false,
    opts = {
        window = {
            show_header = false,
            mappings = {
                ['l'] = 'open',
                ['<Right>'] = 'open',
                ['h'] = 'close_node',
                ['<Left>'] = 'close_node',
                ['?'] = 'show_help',
            },
            width = 40,
            auto_expand_width = true,
        },
        source_selector = {
            winbar = false,
            statusline = true,
        },
        default_component_configs = {
            container = {
                enable_character_fade = false,
            },
            indent = {
                indent_size = 4,
                padding = 0, -- extra padding on left hand side
                -- indent guides
                with_markers = true,
                indent_marker = '│',
                last_indent_marker = '└',
                highlight = 'NeoTreeIndentMarker',
                -- expander config, needed for nesting files
                with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
                expander_collapsed = '',
                expander_expanded = '',
                expander_highlight = 'NeoTreeExpander',
            },
            icon = {
                folder_closed = '',
                folder_open = '',
                folder_empty = '',
                -- The next two settings are only a fallback, if you use
                -- nvim-web-devicons and configure default icons there then
                -- these will never be used.
                default = '*',
                highlight = 'NeoTreeFileIcon',
            },
            modified = {
                symbol = '[+]',
                highlight = 'NeoTreeModified',
            },
            name = {
                trailing_slash = true,
                use_git_status_colors = true,
                highlight = 'NeoTreeFileName',
            },
            git_status = {
                symbols = {
                    -- Change type
                    added = '[Added]', -- or "✚", but this is redundant info if you use git_status_colors on the name
                    modified = '[Modified]', -- or "", but this is redundant info if you use git_status_colors on the name
                    deleted = '[Deleted]', -- this can only be used in the git_status source
                    renamed = '[Renamed]', -- this can only be used in the git_status source
                    -- Status type
                    untracked = '[Untracked]',
                    ignored = '[Ignored]',
                    unstaged = '[Unstaged]',
                    staged = '[Staged]',
                    conflict = '[!Conflict]',
                },
            },
            -- If you don't want to use these columns, you can set `enabled = false` for each of them individually
            file_size = {
                enabled = true,
                required_width = 120, -- min width of window required to show this column
            },
            type = {
                enabled = true,
                required_width = 120, -- min width of window required to show this column
            },
            last_modified = {
                enabled = true,
                required_width = 120, -- min width of window required to show this column
            },
            -- created = {
            -- 	enabled = true,
            -- 	required_width = 100, -- min width of window required to show this column
            -- },
            symlink_target = {
                enabled = true,
            },
        },
        filesystem = {
            filtered_items = {
                -- when true, they will just be displayed differently than normal items
                visible = true,
                hide_dotfiles = false,
                hide_gitignored = false,
                -- only works on Windows for hidden files/directories
                hide_hidden = false,
                hide_by_name = {
                    -- ".DS_Store",
                    -- "thumbs.db",
                    -- "node_modules",
                    -- "__pycache__",
                    -- ".virtual_documents",
                    -- ".git",
                    -- ".python-version",
                    -- ".venv",
                },
                hide_by_pattern = { -- uses glob style patterns
                    --"*.meta",
                    --"*/src/*/tsconfig.json",
                },
                always_show = { -- remains visible even if other settings would normally hide it
                    --".gitignored",
                },
                never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
                    --".DS_Store",
                    --"thumbs.db"
                },
                never_show_by_pattern = { -- uses glob style patterns
                    --".null-ls_*",
                },
            },
            follow_current_file = {
                -- This will find and focus the file in the active buffer every time
                -- the current file is changed while the tree is open.
                enabled = true,

                -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
                leave_dirs_open = false,
            },
            group_empty_dirs = false, -- when true, empty folders will be grouped together
            -- netrw disabled, opening a directory opens neo-tree
            -- in whatever position is specified in window.position
            -- "open_current",  -- netrw disabled, opening a directory opens within the
            -- window like netrw would, regardless of window.position
            -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
            hijack_netrw_behavior = 'open_default',
            -- This will use the OS level file watchers to detect changes instead of
            -- relying on nvim autocmd events.
            use_libuv_file_watcher = true,
            window = {},

            commands = {}, -- Add a custom command or override a global one using the same function name
        },
        buffers = {
            follow_current_file = {
                -- This will find and focus the file in the active buffer every
                -- time the current file is changed while the tree is open.
                enabled = true,
                -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
                leave_dirs_open = false,
            },
            -- when true, empty folders will be grouped together
            group_empty_dirs = true,
            show_unloaded = true,
        },
    },
}
