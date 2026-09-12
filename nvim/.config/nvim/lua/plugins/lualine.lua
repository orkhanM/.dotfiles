return {
  'nvim-lualine/lualine.nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'cuducos/yaml.nvim',
    'phelipetls/jsonpath.nvim',
  },
  lazy = false,
  config = function()
    require('lualine').setup {
      options = {
        icons_enabled = true,
        theme = require 'lualine.themes.catppuccin-mocha',
        -- theme = require 'lualine.themes.molokai',
        -- theme = auto,
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
          statusline = 100,
          tabline = 100,
          winbar = 100,
        },
      },
      sections = {
        -- Add the macro recording status in the mode section
        lualine_a = {
          function()
            local reg = vim.fn.reg_recording()
            -- If a macro is being recorded, show "Recording @<register>"
            if reg ~= '' then
              return 'Recording @' .. reg
            else
              -- Get the full mode name using nvim_get_mode()
              local mode = vim.api.nvim_get_mode().mode
              local mode_map = {
                n = 'NORMAL',
                i = 'INSERT',
                v = 'VISUAL',
                V = 'V-LINE',
                ['^V'] = 'V-BLOCK',
                c = 'COMMAND',
                R = 'REPLACE',
                s = 'SELECT',
                S = 'S-LINE',
                ['^S'] = 'S-BLOCK',
                t = 'TERMINAL',
              }

              -- Return the full mode name
              return mode_map[mode] or mode:upper()
            end
          end,
        },
        -- lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'filename' },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {
        -- lualine_a = { 'tabs' },
        -- lualine_b = {},
        -- lualine_c = {},
        -- lualine_x = {},
        -- lualine_y = {},
        -- lualine_z = { 'buffers' },
      },
      winbar = {},
      inactive_winbar = {},
      extensions = {},
    }
    vim.api.nvim_create_autocmd('FileType', {
      desc = 'add jsonpath to lualine',
      pattern = 'json',
      callback = function()
        require('lualine').setup {
          sections = {
            lualine_c = { 'filename', { require('jsonpath').get, draw_empty = false } },
          },
        }
      end,
    })
    vim.api.nvim_create_autocmd('FileType', {
      desc = 'add yamlkey to lualine',
      pattern = 'yaml',
      callback = function()
        require('lualine').setup {
          sections = {
            lualine_c = { 'filename', { require('yaml_nvim').get_yaml_key, draw_empty = false } },
          },
        }
      end,
    })
  end,
}
