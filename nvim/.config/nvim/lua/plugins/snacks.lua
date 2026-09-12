-- Snacks https://github.com/folke/snacks.nvim/tree/main
-- is a bundle of useful configurations and utilities
return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    animate = { enabled = true },
    dim = { enabled = true },
    bigfile = { enabled = true },
    dashboard = { enabled = false },
    explorer = { enabled = false },
    indent = { enabled = false },
    input = { enabled = false },
    picker = { enabled = false },
    notifier = { enabled = false },
    quickfile = { enabled = false },
    scope = { enabled = false },
    scroll = { enabled = true },
    statuscolumn = { enabled = false },
    styles = { enabled = true },
    words = { enabled = false },
  },
}
