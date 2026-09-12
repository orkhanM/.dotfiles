-- highlights words matching word under cursor in document:
-- https://github.com/RRethy/vim-illuminate
return {
  'RRethy/vim-illuminate',
  lazy = false,
  config = function()
    require('illuminate').configure {}
  end,
}
