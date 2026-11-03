-- nvim-treesitter `main` branch (the `master` branch does not support nvim 0.12+).
-- Requires the `tree-sitter` CLI (brew install tree-sitter-cli) to build parsers.
local ensure_installed = {
  'markdown',
  'markdown_inline',
  'json',
  'javascript',
  'typescript',
  'yaml',
  'html',
  'css',
  'bash',
  'lua',
  'dockerfile',
  'solidity',
  'gitignore',
  'python',
  'nim',
  'hcl',
  'go',
  'c',
  'vue',
  'rust',
  'toml',
}

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    local ts = require 'nvim-treesitter'
    ts.install(ensure_installed)

    local available = {}
    for _, lang in ipairs(ts.get_available()) do
      available[lang] = true
    end

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match)
        if not lang or not available[lang] then
          return
        end

        local function start()
          if not vim.api.nvim_buf_is_valid(args.buf) then
            return
          end
          if pcall(vim.treesitter.start, args.buf, lang) then
            vim.bo[args.buf].syntax = 'ON' -- additional_vim_regex_highlighting
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end

        if vim.list_contains(ts.get_installed(), lang) then
          start()
        else
          -- auto_install
          ts.install(lang):await(vim.schedule_wrap(start))
        end
      end,
    })

    -- incremental selection, using nvim 0.12 built-ins (v_an / v_in)
    vim.keymap.set('n', '<C-s>', 'van', { remap = true, desc = 'Treesitter: init selection' })
    vim.keymap.set('x', '<C-s>', 'an', { remap = true, desc = 'Treesitter: expand selection' })
    vim.keymap.set('x', '<BS>', 'in', { remap = true, desc = 'Treesitter: shrink selection' })
  end,
}
