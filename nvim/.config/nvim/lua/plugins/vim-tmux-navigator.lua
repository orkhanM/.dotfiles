return {
  'christoomey/vim-tmux-navigator',
  lazy = false,
  -- its terminal maps are vim8-only (<C-w>:), nvim just types them into
  -- whatever TUI is running. mine live in config/keymaps.lua
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
  end,
}
