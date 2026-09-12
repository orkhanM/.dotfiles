return {
  'stevearc/conform.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local conform = require 'conform'
    -- list of setup options:
    -- https://github.com/stevearc/conform.nvim?tab=readme-ov-file#options
    conform.setup {

      format_on_save = {
        timeout_ms = 500,
        lsp_format = 'fallback',
      },
      -- list of formatters available:
      -- https://github.com/stevearc/conform.nvim?tab=readme-ov-file#formatters
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'isort', 'black' },
        javascript = { 'prettier' },
        typescript = { 'prettier' },
        json = { 'prettier' },
        yaml = { 'prettier' },
        bash = { 'shfmt' },
        terraform = { 'terraform_fmt' },
        go = { 'golangci-lint' },
        rust = { 'rustfmt' },
      },
    }
    local prettier = require 'conform.formatters.prettier'
    prettier.args = function()
      return {
        '--quote-props',
        'preserve',
        '--insert-final-newline',
        'false',
      }
    end
  end,
  opts = {},
}
