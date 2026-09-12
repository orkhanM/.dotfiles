vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Cycle between buffers
vim.keymap.set('n', '<C-n>', '<Cmd>bnext<CR>') -- Next buffer
vim.keymap.set('n', '<C-p>', '<Cmd>bprevious<CR>') -- Prev buffer

-- Directory Navigation
vim.keymap.set('n', '<leader>m', '<Cmd>Neotree focus<CR>')
vim.keymap.set('n', '<leader>e', '<Cmd>Neotree toggle<CR>')

-- Pane and Window Navigation
vim.keymap.set('n', '<C-h>', 'TmuxNavigateLeft') -- Navigate Left
vim.keymap.set('n', '<C-j>', 'TmuxNavigateDown') -- Navigate Down
vim.keymap.set('n', '<C-k>', 'TmuxNavigateUp') -- Navigate Up
vim.keymap.set('n', '<C-l>', 'TmuxNavigateRight') -- Navigate Right

-- Window Management
vim.keymap.set('n', '<leader>sv', '<Cmd>vsplit<CR>') -- Split Vertically
vim.keymap.set('n', '<leader>sh', '<Cmd>split<CR>') -- Split Horizontally
vim.keymap.set('n', '<leader>s', '<Nop>', { desc = 'Split Prefix' })
vim.keymap.set('n', '<leader>Q', '<Cmd>qall!<CR>', { desc = 'QALL!' }) -- Quit All, NOW!

-- Show Full File-Path
vim.keymap.set('n', '<leader>p', "<Cmd>echo expand('%:pa')<CR>", { desc = 'Show full file path' })

-- virtual_text toggle logic
VirtualTextToggler = {}

VirtualTextToggler.show = false

VirtualTextToggler.toggle = function()
  VirtualTextToggler.show = not VirtualTextToggler.show
  require 'notify'('Toggle VirtualTextToggler.show ' .. tostring(VirtualTextToggler.show), 'info')
  vim.diagnostic.config { virtual_text = VirtualTextToggler.show }
end

vim.api.nvim_set_keymap('n', '<Leader>v', '<Cmd>lua VirtualTextToggler.toggle()<CR>', { silent = true, noremap = true })

-- copilot toggle logic
CopilotToggler = {}
CopilotToggler.enabled = false

CopilotToggler.toggle = function()
  CopilotToggler.enabled = not CopilotToggler.enabled
  require 'notify'('Toggle copilot ' .. tostring(CopilotToggler.enabled), 'info')
  if CopilotToggler.enabled then
    vim.cmd 'Copilot enable'
  else
    vim.cmd 'Copilot disable'
  end
end

vim.api.nvim_set_keymap('n', '<Leader>C', '<Cmd>lua CopilotToggler.toggle()<CR>', { silent = true, noremap = true })
