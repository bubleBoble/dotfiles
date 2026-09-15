return {
    'neovim/nvim-lspconfig', -- optional, only if you want some util helpers; no setup() calls
    dependencies = {
        { 'mason-org/mason.nvim', opts = {} },
        { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
        { 'j-hui/fidget.nvim', opts = {} },
        { 'saghen/blink.cmp' },
    },
    config = function()
        -- DO NOT call require('lspconfig').setup() or lspconfig.<server>.setup{}

        -- 1. LspAttach autocommand (your existing logic is fine)
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
            callback = function(event)
                local map = function(keys, func, desc, mode)
                    mode = mode or 'n'
                    vim.keymap.set(mode, keys, func, {
                        buffer = event.buf,
                        desc = 'LSP: ' .. desc,
                    })
                end

                map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
                map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
                map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
                map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
                map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
                map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
                map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
                map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
                map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

                local function client_supports_method(client, method, bufnr)
                    if vim.fn.has('nvim-0.11') == 1 then
                        return client:supports_method(method, bufnr)
                    else
                        return client.supports_method(method, { bufnr = bufnr })
                    end
                end

                local client = vim.lsp.get_client_by_id(event.client_id)
                if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
                    map('<leader>th', function()
                        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({
                            bufnr = event.buf,
                        }))
                    end, '[T]oggle Inlay [H]ints')
                end
            end,
        })

        -- Diagnostic Config
        -- See :help vim.diagnostic.Opts
        vim.diagnostic.config({
            severity_sort = true,
            float = { border = 'rounded', source = 'if_many' },
            underline = { severity = vim.diagnostic.severity.ERROR },
            signs = vim.g.have_nerd_font and {
                text = {
                    [vim.diagnostic.severity.ERROR] = '󰅚 ',
                    [vim.diagnostic.severity.WARN] = '󰀪 ',
                    [vim.diagnostic.severity.INFO] = '󰋽 ',
                    [vim.diagnostic.severity.HINT] = '󰌶 ',
                },
            } or {},
            virtual_text = {
                source = 'if_many',
                spacing = 2,
                format = function(diagnostic)
                    return diagnostic.message
                end,
            },
        })

        -- blink.cmp adds new LSP capabilities to neovim, LSP clients and servers
        -- can communicate to each other what features they support
        local capabilities = require('blink.cmp').get_lsp_capabilities()

        -- Enable language servers
        --
        -- Add any additional override configuration in the following tables. Available keys are:
        --  - cmd (table): Override the default command used to start the server
        --  - filetypes (table): Override the default list of associated filetypes for the server
        --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
        --  - settings (table): Override the default settings passed when initializing the server.
        --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
        local servers = {
            clangd = {
                cmd = {
                    'clangd',
                    '--header-insertion=never',
                },
            },
            pyright = {
                root_dir = require('lspconfig.util').root_pattern('pyproject.toml', 'setup.py', 'setup.cfg', 'pytest.ini', 'requirements.txt', '.git'),
                capabilities = {
                    workspace = { diagnostics = { refreshSupport = false } },
                },
            },
            lua_ls = {
                settings = {
                    Lua = {
                        completion = {
                            callSnippet = 'Replace',
                        },
                        diagnostics = { disable = { 'missing-fields' } },
                    },
                },
            },
        }

        -- MASON TOOLS INSTALLATION
        -- local ensure_installed = {
        --         'lua-language-server',
        --         'stylua',
        --         'clangd',
        --         'clang-format',
        --         'pyright',
        --         'autopep8',
        --         'rust-analyzer',
        -- }
        -- require('mason-tool-installer').setup({
        --         ensure_installed = ensure_installed,
        -- })

        for name, server in pairs(servers) do
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            vim.lsp.config(name, server)
            vim.lsp.enable(name)
        end

        -- Special Lua Config, as recommended by neovim help docs
        vim.lsp.config('lua_ls', {
            on_init = function(client)
                if client.workspace_folders then
                    local path = client.workspace_folders[1].name
                    if path ~= vim.fn.stdpath('config') and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then
                        return
                    end
                end

                client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                    runtime = {
                        version = 'LuaJIT',
                        path = { 'lua/?.lua', 'lua/?/init.lua' },
                    },
                    workspace = {
                        checkThirdParty = false,
                        -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
                        --  See https://github.com/neovim/nvim-lspconfig/issues/3189
                        library = vim.api.nvim_get_runtime_file('', true),
                    },
                })
            end,
            settings = {
                Lua = {},
            },
        })

        vim.lsp.enable('lua_ls')
    end,
}
