local M = {}

function M.restore_session(session, reopen_neo_tree, focus_neo_tree)
    vim.cmd('source ' .. vim.fn.fnameescape(session))
    if reopen_neo_tree then
        vim.cmd(focus_neo_tree and 'Neotree focus' or 'Neotree show')
    end
end

vim.api.nvim_create_user_command('ReloadConfig', function()
    local persistence = require('persistence')
    if not persistence.active() then
        vim.cmd('restart')
        return
    end

    local reopen_neo_tree = false
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == 'neo-tree' then
            reopen_neo_tree = true
            break
        end
    end
    local focus_neo_tree = vim.bo.filetype == 'neo-tree'
    if reopen_neo_tree then
        vim.cmd('Neotree close')
    end

    local session = persistence.current()
    persistence.save()
    vim.cmd('restart lua require("core.usercommands").restore_session(' .. string.format('%q', session) .. ', '
        .. tostring(reopen_neo_tree) .. ', ' .. tostring(focus_neo_tree) .. ')')
end, { desc = 'Restart Neovim and restore the current session' })

return M
