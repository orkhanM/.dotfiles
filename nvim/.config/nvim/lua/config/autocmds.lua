-- remove trailing whitespaces on save
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  pattern = { '*' },
  command = [[%s/\s\+$//e]],
})

-- On LspAttach we create key bindings for LSP commands
--vim.api.nvim_create_autocmd("LspAttach", {
--  callback = function(e)
--    local opts = { buffer = e.buf }
--    vim.keymap.set("n", "gd", function()
--      vim.lsp.buf.definition()
--    end, opts)
--    vim.keymap.set("n", "K", function()
--      vim.lsp.buf.hover()
--    end, opts)
--    vim.keymap.set("n", "<leader>vws", function()
--      vim.lsp.buf.workspace_symbol()
--    end, opts)
--    vim.keymap.set("n", "<leader>vd", function()
--      vim.diagnostic.open_float()
--    end, opts)
--    vim.keymap.set("n", "[d", function()
--      vim.diagnostic.goto_next()
--    end, opts)
--    vim.keymap.set("n", "]d", function()
--      vim.diagnostic.goto_prev()
--    end, opts)
--    vim.keymap.set("n", "<leader>vca", function()
--      vim.lsp.buf.code_action()
--    end, opts)
--    vim.keymap.set("n", "<leader>vrr", function()
--      vim.lsp.buf.references()
--    end, opts)
--    vim.keymap.set("n", "<leader>vrn", function()
--      vim.lsp.buf.rename()
--    end, opts)
--    vim.keymap.set("i", "<C-h>", function()
--      vim.lsp.buf.signature_help()
--    end, opts)
--  end,
--})

-- highlight on yank
local highlight_yank_group = vim.api.nvim_create_augroup('HighlightYankGroup', {})
vim.api.nvim_create_autocmd('TextYankPost', {
  group = highlight_yank_group,
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Enhanced TODO comment highlighting (matches TODO with or without colon)
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter', 'FileType' }, {
  pattern = '*',
  callback = function()
    -- Match TODO keywords with optional colon
    vim.fn.matchadd('Todo', [[\<\(TODO\|FIXME\|FIX\|HACK\|WARN\|WARNING\|XXX\|NOTE\|INFO\|PERF\|OPTIM\|TEST\)\>]])
  end,
})
