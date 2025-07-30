-- ~/.config/nvim/lua/custom/configs/sessions.lua ------------------
local obs = require 'obsidian'
local Path = require 'plenary.path'
local M = {}

-- -----------------------------------------------------------------
-- helper that inserts template & does {{…}} substitutions
local function open_and_fill(abs_path, template, vars)
  Path:new(abs_path):parent():mkdir { parents = true }
  vim.cmd('edit ' .. tostring(abs_path))

  if vim.fn.line '$' == 1 and vim.fn.getline(1) == '' then
    -- drop the template
    local ok = pcall(vim.cmd, 'ObsidianTemplate ' .. template)
    if not ok then
      vim.notify("Template '" .. template .. "' not found", vim.log.levels.WARN)
    end

    -- do placeholder replacement
    for k, v in pairs(vars) do
      vim.cmd(('%%s/{{%s}}/%s/ge'):format(k, v))
    end
  end
end

-- -----------------------------------------------------------------
-- public helpers
function M.new_project(slug)
  local dir = obs.get_client().dir / 'Projects'
  open_and_fill(dir / (slug .. '.md'), 'design-project', {
    project = slug,
    start = os.date '%Y-%m-%d@%H:%M',
  })
end

function M.new_session(slug)
  local start = os.date '%Y-%m-%d@%H-%M'
  local ts = os.date '%Y-%m-%d'
  local dir = obs.get_client().dir / 'Sessions'
  open_and_fill(dir / (slug .. '-' .. ts .. '.md'), 'design-session', {
    project = slug,
    start = start,
  })
end

-- -----------------------------------------------------------------
-- user commands
vim.api.nvim_create_user_command('ObsidianNewProject', function(o)
  local slug = (#o.args > 0) and o.args or vim.fn.input 'Project slug: '
  if slug ~= '' then
    M.new_project(slug)
  end
end, { nargs = '?' })

vim.api.nvim_create_user_command('ObsidianNewSession', function(o)
  local slug = (#o.args > 0) and o.args or vim.fn.input 'Project slug: '
  if slug ~= '' then
    M.new_session(slug)
  end
end, { nargs = '?' })

-- key-maps
vim.keymap.set('n', '<leader>zr', '<cmd>ObsidianNewProject<CR>', { desc = 'New project note' })
vim.keymap.set('n', '<leader>zs', '<cmd>ObsidianNewSession<CR>', { desc = 'New session note' })

return M
