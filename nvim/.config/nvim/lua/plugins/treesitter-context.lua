return {
  'nvim-treesitter/nvim-treesitter-context',
  opts = function()
    -- https://github.com/nvim-treesitter/nvim-treesitter-context
    return {
      enable = true,
      multiwindow = false,
      max_lines = 0,
      min_window_height = 0,
      line_numbers = true,
      multiline_threshold = 20,
      trim_scope = 'outer',
      mode = 'cursor',
      separator = '',
      zindex = 20,
    }
  end,
}
