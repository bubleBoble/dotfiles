return {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-tree/nvim-web-devicons', -- keep it installed, but we neutralize it below
        'MunifTanjim/nui.nvim',
        {
            's1n7ax/nvim-window-picker',
            version = '2.*',
            config = function()
                require('window-picker').setup({
                    filter_rules = {
                        include_current_win = false,
                        autoselect_one = true,
                        bo = {
                            filetype = { 'neo-tree', 'neo-tree-popup', 'notify' },
                            buftype = { 'terminal', 'quickfix' },
                        },
                    },
                })
            end,
        },
    },
    config = function()
        -- Remove diagnostic sign icons
        vim.fn.sign_define('DiagnosticSignError', { text = '', texthl = 'DiagnosticSignError' })
        vim.fn.sign_define('DiagnosticSignWarn', { text = '', texthl = 'DiagnosticSignWarn' })
        vim.fn.sign_define('DiagnosticSignInfo', { text = '', texthl = 'DiagnosticSignInfo' })
        vim.fn.sign_define('DiagnosticSignHint', { text = '', texthl = 'DiagnosticSignHint' })

        -- Disable ALL filetype icons coming from nvim-web-devicons
        local ok_devicons, devicons = pcall(require, 'nvim-web-devicons')
        if ok_devicons then
            -- Return nil so neo-tree treats it as "no icon available"
            devicons.get_icon = function()
                return nil
            end
            devicons.get_icon_by_filetype = function()
                return nil
            end
            devicons.get_icon_color = function()
                return nil
            end
            devicons.get_icon_colors = function()
                return nil
            end
        end

        require('neo-tree').setup({
            popup_border_style = 'NC',
            enable_git_status = false,
            enable_diagnostics = false,
            open_files_do_not_replace_types = { 'terminal', 'trouble', 'qf' },
            sort_case_insensitive = false,
            sort_function = nil,

            default_component_configs = {
                container = { enable_character_fade = true },

                indent = {
                    indent_size = 2,
                    padding = 1,
                    with_markers = false,
                    indent_marker = '',
                    last_indent_marker = '',
                    highlight = 'NeoTreeIndentMarker',
                    with_expanders = nil,
                    expander_collapsed = '',
                    expander_expanded = '',
                    expander_highlight = 'NeoTreeExpander',
                },

                -- These are only the built-in fallback glyphs; devicons are neutralized above
                icon = {
                    folder_closed = '',
                    folder_open = '',
                    folder_empty = '',
                    default = '',
                    highlight = 'NeoTreeFileIcon',
                },

                modified = { symbol = '', highlight = 'NeoTreeModified' },

                name = {
                    trailing_slash = false,
                    use_git_status_colors = true,
                    highlight = 'NeoTreeFileName',
                },

                git_status = {
                    symbols = {
                        added = '',
                        modified = '',
                        deleted = '',
                        renamed = '',
                        untracked = '',
                        ignored = '',
                        unstaged = '',
                        staged = '',
                        conflict = '',
                    },
                },

                file_size = { enabled = false, required_width = 64 },
                type = { enabled = false, required_width = 122 },
                last_modified = { enabled = false, required_width = 88 },
                created = { enabled = false, required_width = 110 },
                symlink_target = { enabled = false },
            },

            commands = {},

            window = {
                show_header = false,
                position = 'left',
                popup = {
                    size = { width = 0.8, height = 0.8 },
                    border = { style = { '+', '-', '+', '|', '+', '-', '+', '|' } },
                },
                width = 40,
                mapping_options = { noremap = true, nowait = true },
                mappings = {
                    ['<space>'] = { 'toggle_node', nowait = false },
                    ['<2-LeftMouse>'] = 'open',
                    ['<cr>'] = 'open',
                    ['<esc>'] = 'cancel',
                    ['P'] = { 'toggle_preview', config = { use_float = false } },
                    ['l'] = 'open',
                    ['S'] = 'split_with_window_picker',
                    ['s'] = 'vsplit_with_window_picker',
                    ['t'] = 'open_tabnew',
                    ['w'] = 'open_with_window_picker',
                    ['C'] = 'close_node',
                    ['z'] = 'close_all_nodes',
                    ['a'] = { 'add', config = { show_path = 'none' } },
                    ['A'] = 'add_directory',
                    ['d'] = 'delete',
                    ['r'] = 'rename',
                    ['y'] = 'copy_to_clipboard',
                    ['x'] = 'cut_to_clipboard',
                    ['p'] = 'paste_from_clipboard',
                    ['c'] = 'copy',
                    ['m'] = 'move',
                    ['q'] = 'close_window',
                    ['R'] = 'refresh',
                    ['?'] = 'show_help',
                    ['<'] = 'prev_source',
                    ['>'] = 'next_source',
                    ['i'] = 'show_file_details',
                },
            },

            nesting_rules = {},

            filesystem = {
                filtered_items = {
                    visible = false,
                    hide_dotfiles = false,
                    hide_gitignored = false,
                    hide_hidden = false,
                    hide_by_name = {
                        '.DS_Store',
                        'thumbs.db',
                        'node_modules',
                        '__pycache__',
                        '.virtual_documents',
                        '.git',
                        '.python-version',
                        '.venv',
                    },
                    hide_by_pattern = {},
                    always_show = {},
                    never_show = {},
                    never_show_by_pattern = {},
                },
                follow_current_file = { enabled = false, leave_dirs_open = false },
                group_empty_dirs = false,
                hijack_netrw_behavior = 'open_default',
                use_libuv_file_watcher = true,
                window = {
                    mappings = {
                        ['<bs>'] = 'navigate_up',
                        ['.'] = 'set_root',
                        ['H'] = 'toggle_hidden',
                        ['/'] = 'fuzzy_finder',
                        ['D'] = 'fuzzy_finder_directory',
                        ['#'] = 'fuzzy_sorter',
                        ['f'] = 'filter_on_submit',
                        ['<c-x>'] = 'clear_filter',
                        ['[g'] = 'prev_git_modified',
                        [']g'] = 'next_git_modified',
                        ['o'] = { 'show_help', nowait = false, config = { title = 'Order by', prefix_key = 'o' } },
                        ['oc'] = { 'order_by_created', nowait = false },
                        ['od'] = { 'order_by_diagnostics', nowait = false },
                        ['og'] = { 'order_by_git_status', nowait = false },
                        ['om'] = { 'order_by_modified', nowait = false },
                        ['on'] = { 'order_by_name', nowait = false },
                        ['os'] = { 'order_by_size', nowait = false },
                        ['ot'] = { 'order_by_type', nowait = false },
                    },
                    fuzzy_finder_mappings = {
                        ['<down>'] = 'move_cursor_down',
                        ['<C-n>'] = 'move_cursor_down',
                        ['<up>'] = 'move_cursor_up',
                        ['<C-p>'] = 'move_cursor_up',
                    },
                },
                commands = {},
            },

            buffers = {
                follow_current_file = { enabled = true, leave_dirs_open = false },
                group_empty_dirs = true,
                show_unloaded = true,
                window = {
                    mappings = {
                        ['bd'] = 'buffer_delete',
                        ['<bs>'] = 'navigate_up',
                        ['.'] = 'set_root',
                        ['o'] = { 'show_help', nowait = false, config = { title = 'Order by', prefix_key = 'o' } },
                        ['oc'] = { 'order_by_created', nowait = false },
                        ['od'] = { 'order_by_diagnostics', nowait = false },
                        ['om'] = { 'order_by_modified', nowait = false },
                        ['on'] = { 'order_by_name', nowait = false },
                        ['os'] = { 'order_by_size', nowait = false },
                        ['ot'] = { 'order_by_type', nowait = false },
                    },
                },
            },

            git_status = {
                window = {
                    mappings = {
                        ['A'] = 'git_add_all',
                        ['gu'] = 'git_unstage_file',
                        ['ga'] = 'git_add_file',
                        ['gr'] = 'git_revert_file',
                        ['gc'] = 'git_commit',
                        ['gp'] = 'git_push',
                        ['gg'] = 'git_commit_and_push',
                        ['o'] = { 'show_help', nowait = false, config = { title = 'Order by', prefix_key = 'o' } },
                        ['oc'] = { 'order_by_created', nowait = false },
                        ['od'] = { 'order_by_diagnostics', nowait = false },
                        ['om'] = { 'order_by_modified', nowait = false },
                        ['on'] = { 'order_by_name', nowait = false },
                        ['os'] = { 'order_by_size', nowait = false },
                        ['ot'] = { 'order_by_type', nowait = false },
                    },
                },
            },
        })

        vim.cmd([[nnoremap \ :Neotree reveal<cr>]])
        vim.keymap.set('n', '<leader>e', ':Neotree toggle position=left<CR>', { noremap = true, silent = true })
    end,
}
