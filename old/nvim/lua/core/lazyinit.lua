-- :help lazy.nvim
-- or https://github.com/folke/lazy.nvim for more info

-- Bootstrap code for Neovim's lazy.nvim plugin manager
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local lockfile = vim.fn.stdpath('config') .. '/lazy-lock.json'
    local lock = vim.json.decode(table.concat(vim.fn.readfile(lockfile), '\n'))
    local lazy = assert(lock['lazy.nvim'], 'Missing lazy.nvim entry in ' .. lockfile)

    local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=' .. lazy.branch, lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        error('Error cloning lazy.nvim:\n' .. out)
    end

    out = vim.fn.system({ 'git', '-C', lazypath, 'checkout', '--detach', lazy.commit })
    if vim.v.shell_error ~= 0 then
        error('Error checking out locked lazy.nvim commit ' .. lazy.commit .. ':\n' .. out)
    end
end

-- Make sure lazy.nvim is loaded before any plugins.
vim.opt.rtp:prepend(lazypath)
