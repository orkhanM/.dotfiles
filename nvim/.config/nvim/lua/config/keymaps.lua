vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Cycle between buffers
vim.keymap.set('n', '<C-n>', '<Cmd>bnext<CR>') -- Next buffer
vim.keymap.set('n', '<C-p>', '<Cmd>bprevious<CR>') -- Prev buffer

-- Directory Navigation
vim.keymap.set('n', '<leader>m', '<Cmd>Neotree focus<CR>')
vim.keymap.set('n', '<leader>e', '<Cmd>Neotree toggle<CR>')

-- Pane and Window Navigation
-- <Cmd>, not ':', or lazygit eats the rhs as keystrokes
vim.keymap.set('n', '<C-h>', '<Cmd>TmuxNavigateLeft<CR>') -- Navigate Left
vim.keymap.set('n', '<C-j>', '<Cmd>TmuxNavigateDown<CR>') -- Navigate Down
vim.keymap.set('n', '<C-k>', '<Cmd>TmuxNavigateUp<CR>') -- Navigate Up
vim.keymap.set('n', '<C-l>', '<Cmd>TmuxNavigateRight<CR>') -- Navigate Right
vim.keymap.set('n', '<C-\\>', '<Cmd>TmuxNavigatePrevious<CR>') -- Navigate Previous

-- same from terminal mode, except fzf which wants the keys itself
local tmux_pane = { Left = 'L', Down = 'D', Up = 'U', Right = 'R' }

local function tmux_navigate(key, direction)
  return function()
    if vim.bo.filetype == 'fzf' then
      return key
    end
    -- wincmd out of a float drops me in the window behind lazygit, in normal
    -- mode, so from a float go straight to the tmux pane and stay put
    if vim.api.nvim_win_get_config(0).relative ~= '' then
      if vim.env.TMUX then
        vim.system { 'tmux', 'select-pane', '-t', vim.env.TMUX_PANE, '-' .. tmux_pane[direction] }
      end
      return ''
    end
    return '<Cmd>TmuxNavigate' .. direction .. '<CR>'
  end
end

vim.keymap.set('t', '<C-h>', tmux_navigate('<C-h>', 'Left'), { expr = true })
vim.keymap.set('t', '<C-j>', tmux_navigate('<C-j>', 'Down'), { expr = true })
vim.keymap.set('t', '<C-k>', tmux_navigate('<C-k>', 'Up'), { expr = true })
vim.keymap.set('t', '<C-l>', tmux_navigate('<C-l>', 'Right'), { expr = true })

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
