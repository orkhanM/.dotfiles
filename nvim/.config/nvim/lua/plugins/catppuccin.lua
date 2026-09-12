return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    config = function()
      require('catppuccin').setup {
        flavor = 'mocha',
        background = { -- :h background
          light = 'mocha',
          dark = 'mocha',
        },
        transparent_background = true, -- disables setting the background color.
        show_end_of_buffer = true, -- shows the '~' characters after the end of buffers
        term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
        dim_inactive = {
          enabled = true, -- dims the background color of inactive window
          shade = 'dark',
          percentage = 0.15, -- percentage of the shade to apply to the inactive window
        },
        no_italic = false, -- Force no italic
        no_bold = false, -- Force no bold
        no_underline = true, -- Force no underline
        --styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
        --  comments = { "italic" }, -- Change the style of comments
        --  conditionals = { "italic" },
        --  loops = {},
        --  functions = {},
        --  keywords = {},
        --  strings = {},
        --  variables = {},
        --  numbers = {},
        --  booleans = {},
        --  properties = {},
        --  types = {},
        --  operators = {},
        --  -- miscs = {}, -- Uncomment to turn off hard-coded styles
        --},
        --color_overrides = {},
        custom_highlights = function(colors)
          return {
            WinSeperator = { fg = colors.flamingo },
          }
        end,
        --default_integrations = true,
        integrations = {
          neotree = true,
          cmp = true,
          --  aerial = true,
          --  alpha = true, dashboard = true,
          --  flash = true,
          gitsigns = true,
          --  headlines = true,
          illuminate = true,
          indent_blankline = { enabled = true },
          --  leap = true,
          lsp_trouble = true,
          mason = true,
          markdown = true,
          --  --mini = true,
          --  mini = {
          --    enabled = true,
          --    indentscope_color = "",
          --  },
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { 'italic' },
              hints = { 'italic' },
              warnings = { 'italic' },
              information = { 'italic' },
              ok = { 'italic' },
            },
            underlines = {
              errors = { 'underline' },
              hints = { 'underline' },
              warnings = { 'underline' },
              information = { 'underline' },
              ok = { 'underline' },
            },
            inlay_hints = {
              background = true,
            },
          },
          -- navic = { enabled = true, custom_bg = 'lualine' },
          --  neotest = true,
          noice = true,
          notify = true,
          semantic_tokens = true,
          telescope = true,
          treesitter = true,
          treesitter_context = true,
          which_key = true,
          nvimtree = true,
        },
      }
      vim.cmd.colorscheme 'catppuccin-mocha'
    end,
  },
}
