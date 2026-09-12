return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  version = 'v2.1.0',
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 100
  end,
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
}
