local opt = vim.opt

-- Tabs are 2 spaces >_>
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
-- spacese not tabs
opt.expandtab = true
-- let line go off screen vs wrapping
opt.wrap = false

-- Search
--
-- finds matches as we type our search
opt.incsearch = true
-- will return uppercase results for lowercase searches
opt.ignorecase = true
-- if capitilaztion is explicitly used then enforce
opt.smartcase = true
-- highlight search
opt.hlsearch = true

-- Appearance
--
-- line numbers
opt.relativenumber = true
-- color support
opt.termguicolors = true
-- 100 character column marker
--opt.colorcolumn = '100'
-- space for notify / inline messages
opt.signcolumn = 'yes'
-- 1 row for cmd mode
opt.cmdheight = 1
-- buffer zone at bottom of screen for scrolling
opt.scrolloff = 10
-- autocompletion behavior
-- - menuone only one item shown
-- - nothing will be inserted by default
-- - nothing will be selected by default
opt.completeopt = 'menuone,noinsert,noselect'

-- Behavior
--
-- vsplit to the right
opt.splitright = true
-- hsplit to bottom
opt.splitbelow = true
-- able to switch buffers without having to save
opt.hidden = true
-- updatetime for CursorHold autocmds
opt.updatetime = 1000
-- ring loud baby
opt.errorbells = true
-- turn off swapfiles
opt.swapfile = false
-- no backups?!
opt.backup = false
-- undo directory
opt.undofile = true
opt.undodir = vim.fn.expand '~/.local/cache/nvim/undodir'
-- backspace
opt.backspace = 'indent,eol,start'
opt.autochdir = false
opt.mouse:append 'a'
opt.clipboard:append 'unnamedplus'
-- yank/copy to system clipboard
--opt.clipboard = "unnamedplus"
opt.modifiable = true
opt.guicursor =
  'n-v-c:block,i-ci-ve:block,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175'
opt.encoding = 'UTF-8'
