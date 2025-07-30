return {
  {
    'epwalsh/obsidian.nvim',
    version = '*',
    lazy = true,
    ft = 'markdown',
    dependencies = { 'nvim-lua/plenary.nvim' },

    opts = {
      workspaces = {
        { name = 'main', path = '~/Documents/cello-main/' },
      },

      templates = {
        folder = '~/Documents/cello-main/Templates/',
        date_format = '%Y-%m-%d-%a',
        time_format = '%H:%M',
        substitutions = {
          today = function()
            return os.date '%Y-%m-%d'
          end,
          tomorrow = function()
            return os.date('%Y-%m-%d', os.time() + 86400)
          end,
          yesterday = function()
            return os.date('%Y-%m-%d', os.time() - 86400)
          end,
          now = function()
            return os.date '%Y-%m-%d-%H:%M'
          end,
        },
      },

      daily_notes = {
        folder = 'Dailies/',
        date_format = '%Y-%m-%d',
        template = '~/Documents/cello-main/Dailies/Daily-Template.md',
      },

      mappings = {
        -- gf passthrough (your original)
        ['gf'] = {
          action = function()
            return require('obsidian').util.gf_passthrough()
          end,
          opts = { noremap = false, expr = true, buffer = true },
        },

        -- toggle on this line, then go to EOL + insert
        ['<leader>ch'] = {
          action = function()
            require('obsidian').util.toggle_checkbox()
          end,
          opts = { buffer = true, desc = 'Toggle checkbox + insert' },
        },

        -- open new line, insert checkbox, then go to EOL + insert
        ['<leader>cn'] = {
          action = function()
            local bufnr = 0
            -- 1) what row are we on?
            local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
            -- 2) get the indent of that line
            local line = vim.fn.getline(row)
            local indent = line:match '^%s*' or ''
            -- 3) build your checkbox line
            local ck = indent .. '- [ ]  '
            -- 4) insert it *below* (row is 1-based, set_lines uses 0-based start/end)
            vim.api.nvim_buf_set_lines(bufnr, row, row, false, { ck })
            -- 5) move cursor to end of the new line
            vim.api.nvim_win_set_cursor(0, { row + 1, #ck })
            -- 6) enter insert mode
            vim.cmd 'startinsert'
          end,
          opts = { buffer = true, desc = 'New checkbox + insert' },
        },
      },

      completion = {
        nvim_cmp = true,
        min_chars = 2,
      },
    },

    config = function(_, opts)
      -- let obsidian.nvim do its thing
      require('obsidian').setup(opts)

      -- your other non-Obsidian keymaps
      local km = vim.keymap.set
      km('n', '<leader>zn', vim.cmd.ObsidianSearch, { desc = 'Search / new note' })
      km('v', '<leader>ze', vim.cmd.ObsidianExtractNote, { desc = 'Extract note from selection' })
      km('n', '<leader>zt', vim.cmd.ObsidianTemplate, { desc = 'Insert template' })
      km('n', '<leader>zd', vim.cmd.ObsidianToday, { desc = 'Daily note: today' })
      km('n', '<leader>zy', vim.cmd.ObsidianYesterday, { desc = 'Daily note: yesterday' })
      km('n', '<leader>zm', vim.cmd.ObsidianTomorrow, { desc = 'Daily note: tomorrow' })
      km('v', '<leader>zl', vim.cmd.ObsidianLink, { desc = 'Link selection' })
      km('n', '<leader>zb', vim.cmd.ObsidianBacklinks, { desc = 'Show backlinks' })
    end,
  },
}
