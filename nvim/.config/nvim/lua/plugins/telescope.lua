return {
  'nvim-telescope/telescope.nvim',
  -- branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
    },
    'rcarriga/nvim-notify',
    'nvim-telescope/telescope-ui-select.nvim',
  },
  config = function()
    -- TODO: add live grep args, fix mapping for fuzzy refine
    local telescope = require 'telescope'
    telescope.setup {
      defaults = {
        mappings = {
          i = {
            ['<C-h>'] = 'which_key',
            ['<C-j>'] = 'move_selection_next',
            ['<C-k>'] = 'move_selection_previous',
          },
        },
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          '--hidden',
          '--glob=!.git/*',
        },
      },
      pickers = {
        find_files = {
          theme = 'dropdown',
          previewer = true,
          hidden = true,
          find_command = { 'rg', '--files', '--hidden', '--glob', '!.git/*' },
        },
        live_grep = {
          theme = 'dropdown',
          previewer = true,
        },
        buffers = {
          theme = 'dropdown',
          previewer = true,
        },
      },
    }

    -- Load extensions after setup
    telescope.load_extension 'notify'
    telescope.load_extension 'ui-select'
  end,
  keys = {
    { '<leader>f', '<Nop>', desc = '+Telescope Prefix' },
    { '<leader>fk', '<Cmd>Telescope keymaps<CR>', desc = 'Keymaps' },
    { '<leader>fh', '<Cmd>Telescope help_tags<CR>', desc = 'Help tags' },
    { '<leader>ff', '<Cmd>Telescope find_files<CR>', desc = 'Find files' },
    { '<leader>fg', '<Cmd>Telescope live_grep<CR>', desc = 'Live grep' },
    { '<leader>f/', '<Cmd>Telescope current_buffer_fuzzy_find<CR>', desc = 'Fuzzy find in buffer' },
    { '<leader>fl', '<Cmd>Telescope git_status<CR>', desc = 'Live grep' },
    { '<leader>fb', '<Cmd>Telescope buffers<CR>', desc = 'Buffers' },
    { '<leader>fs', '<Cmd>Telescope lsp_document_symbols<CR>', desc = 'LSP symbols' },
    { '<leader>fd', '<Cmd>Telescope diagnostics<CR>', desc = 'Diagnostics' },
    { '<leader>fy', '<Cmd>YAMLTelescope<CR>', desc = 'Yamlyamlyaml' },
    { '<leader>ft', '<Cmd>TodoTelescope<CR>', desc = 'Todo' },
  },
}
