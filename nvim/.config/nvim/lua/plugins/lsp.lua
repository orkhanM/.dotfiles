return {
  'williamboman/mason-lspconfig.nvim',
  dependencies = {
    -- lsp package manager
    'williamboman/mason.nvim',
    -- lsp client configurations
    'neovim/nvim-lspconfig',
    -- install non lsp mason packages
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'towolf/vim-helm', ft = 'helm' },
  },

  config = function()
    vim.notify = require 'notify'
    require('mason').setup {
      ui = {
        -- without this setting there is no border :(
        border = 'rounded',
      },
    }

    -- install non-lsp mason packages using mason-tool-installer
    require('mason-tool-installer').setup {
      ensure_installed = {
        'flake8',
        'golangci-lint',
        'golangci-lint-langserver',
        'pylint',
        'tflint',
        'black',
        'isort',
        'prettier',
        'prettierd',
        'stylua',
        'ansible-lint',
        'ansiblels',
        'ts_ls',
      },
    }

    -- mason-lspconfig v2 dropped the `handlers` table that used to wrap all of
    -- this. it now only installs servers and turns them on with
    -- vim.lsp.enable(); per-server settings go through vim.lsp.config() and
    -- what used to be on_attach is the LspAttach autocmd at the bottom.
    require('mason-lspconfig').setup {
      -- https://github.com/mason-org/mason-lspconfig.nvim#available-lsp-servers
      ensure_installed = {
        'bashls',
        'pyright',
        'tflint',
        'terraformls',
        'lua_ls',
        'jsonls',
        'clangd',
        'helm_ls',
        'yamlls',
        'gopls',
        'rust_analyzer',
      },
    }

    local capabilities = require('blink.cmp').get_lsp_capabilities()
    capabilities.textDocument.foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true,
    }

    -- merged into every server, so it replaces passing capabilities to each
    vim.lsp.config('*', { capabilities = capabilities })

    vim.lsp.config('lua_ls', {
      on_init = function(client)
        -- a project with its own .luarc.json knows better than we do
        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if
            path ~= vim.fn.stdpath 'config'
            and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
          then
            return
          end
        end

        client.settings = vim.tbl_deep_extend('force', client.settings or {}, {
          Lua = {
            runtime = { version = 'LuaJIT' },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
                '${3rd}/luv/library',
              },
            },
          },
        })
        client:notify('workspace/didChangeConfiguration', { settings = client.settings })
      end,
      settings = { Lua = {} },
    })

    -- YAMLLS See:
    --      https://github.com/redhat-developer/yaml-language-server#language-server-settings
    vim.lsp.config('yamlls', {
      settings = {
        yaml = {
          schemaStore = { enable = true },
          hover = { enable = true },
          -- getem from https://www.schemastore.org/json/
          schemas = {
            -- argo workflows
            --['https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json'] = '/*.yaml',
            -- k8s resources
            --['kubernetes'] = '/*.yaml',
          },
        },
      },
    })

    vim.lsp.config('helm_ls', {
      settings = {
        ['helm-ls'] = {
          logLevel = 'info',
          valuesFiles = {
            mainValuesFile = 'values.yaml',
            lintOverlayValuesFile = 'values.lint.yaml',
            additionalValuesFilesGlobPattern = 'values*.yaml',
          },
          yamlls = {
            enabled = true,
            enabledForFilesGlob = '*.{yaml,yml}',
            diagnosticsLimit = 50,
            showDiagnosticsDirectly = false,
            path = 'yaml-language-server',
            config = {
              schemas = {
                kubernetes = 'templates/**',
              },
              completion = true,
              hover = true,
            },
          },
        },
      },
    })

    -- rustfmt/clippy/rust-src come from rustup (see `make rust`), not mason
    vim.lsp.config('rust_analyzer', {
      settings = {
        ['rust-analyzer'] = {
          checkOnSave = true,
          check = { command = 'clippy' },
          procMacro = { enable = true },
        },
      },
    })

    -- Point pyright at the project's venv. Without this it uses whatever
    -- python3 is first on PATH, which resolves the stdlib to the wrong version
    -- and can't see site-packages at all -- goto-definition on an installed
    -- package just returns nothing.
    --
    -- venvPath is resolved relative to the workspace root, so one static value
    -- covers every project rather than computing a path per root. It has to be
    -- set here and not in before_init/on_init: pyright resolves imports during
    -- initialize, and neither hook's settings reach it in time.
    vim.lsp.config('pyright', {
      settings = {
        python = {
          pythonPath = '.venv/bin/python',
        },
      },
    })

    vim.lsp.config('terraformls', {
      cmd = { 'terraform-ls', 'serve' },
      filetypes = { 'terraform', 'terraform-vars', 'tf', 'tfvars', 'hcl' },
      settings = {
        terraform = {
          terraform = { path = 'terraform' },
        },
      },
    })

    vim.lsp.config('bashls', {
      filetypes = { 'sh', 'bash', 'zsh' },
      settings = {
        globPattern = '**/*@(.sh|.zsh|.inc|.bash|.command)',
      },
    })

    vim.lsp.config('ansiblels', {
      filetypes = { 'yaml.ansible', 'ansible' },
      settings = {
        ansible = {
          ansible = { path = 'ansible' },
          executionEnvironment = { enabled = false },
          python = { interpreterPath = 'python3' },
          validation = {
            enabled = true,
            lint = { enabled = true, path = 'ansible-lint' },
          },
        },
      },
    })

    -- mason-lspconfig only auto-enables what it installed; these come from
    -- mason-tool-installer, so turn them on here.
    vim.lsp.enable { 'ts_ls', 'ansiblels', 'golangci_lint_ls' }

    -- ansible playbooks are yaml, so the filetype needs help
    vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
      pattern = { '*/playbooks/*.yml', '*/roles/*.yml', '*/tasks/*.yml', 'playbook.yml', '*/ansible/*.yml' },
      callback = function()
        vim.bo.filetype = 'yaml.ansible'
      end,
    })

    -- what on_attach used to do. fires once per client per buffer.
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('lsp_attach', { clear = true }),
      callback = function(ev)
        local bufnr = ev.buf
        local client = vim.lsp.get_client_by_id(ev.data.client_id)

        local map = function(mode, lhs, rhs, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, lhs, rhs, opts)
        end
        map('n', 'gD', vim.lsp.buf.declaration, { desc = '[LSP] Goto declaration' })
        map('n', 'gd', vim.lsp.buf.definition, { desc = '[LSP] Goto defition' })
        map('n', 'gsvd', ':vsplit | lua vim.lsp.buf.definition()<CR>', { desc = '[LSP] Vsplit Goto defition' })
        map('n', 'gshd', ':split | lua vim.lsp.buf.definition()<CR>', { desc = '[LSP] Hsplit Goto defition' })
        map('n', 'gy', vim.lsp.buf.type_definition, { desc = '[LSP] Goto type' })
        map('n', 'gi', vim.lsp.buf.implementation, { desc = '[LSP] Goto implementation' })
        -- moved to fzf as it allows to easily open in new tab/split/etc
        -- map("n", "gr", vim.lsp.buf.references, {desc="Show references [LSP]"})
        map('n', 'K', vim.lsp.buf.hover, { desc = '[LSP] Show type' })
        map('n', 'L', vim.lsp.buf.signature_help, { desc = '[LSP] Show signature' })
        map('n', '<leader>rn', vim.lsp.buf.rename, { desc = '[LSP] Rename' })
        map('n', '<leader>q', '<Nop>', { desc = '[LSP] Quick fix menu' })
        map('n', '<leader>qf', ':CodeActionMenu<cr>', { desc = '[LSP] Quick fix menu' })
        map('n', '[d', vim.diagnostic.goto_prev, { desc = '[LSP] Goto prev diagnostic' })
        map('n', ']d', vim.diagnostic.goto_next, { desc = '[LSP] Goto next diagnostic' })

        vim.api.nvim_buf_create_user_command(bufnr, 'LspHover', vim.lsp.buf.hover, {})
        vim.api.nvim_buf_create_user_command(bufnr, 'LspSignature', vim.lsp.buf.signature_help, {})
        vim.api.nvim_buf_create_user_command(bufnr, 'LspDef', vim.lsp.buf.definition, {})
        vim.api.nvim_buf_create_user_command(bufnr, 'LspTypeDef', vim.lsp.buf.type_definition, {})
        vim.api.nvim_buf_create_user_command(bufnr, 'LspImplementation', vim.lsp.buf.implementation, {})
        vim.api.nvim_buf_create_user_command(bufnr, 'LspRefs', vim.lsp.buf.references, {})
        vim.api.nvim_buf_create_user_command(bufnr, 'LspCodeAction', vim.lsp.buf.code_action, {})
        vim.api.nvim_buf_create_user_command(bufnr, 'LspRename', vim.lsp.buf.rename, {})
        vim.api.nvim_buf_create_user_command(bufnr, 'LspDiagShow', vim.diagnostic.open_float, {})
        vim.api.nvim_buf_create_user_command(bufnr, 'LspDiagPrev', vim.diagnostic.goto_prev, {})
        vim.api.nvim_buf_create_user_command(bufnr, 'LspDiagNext', vim.diagnostic.goto_next, {})

        -- disable semantic tokens and let treesitter handle syntax highlighting
        -- nil-ing the capability isn't enough: it races LspAttach's deferred
        -- start() and then crashes in send_request(), so stop() it too
        if client then
          client.server_capabilities.semanticTokensProvider = nil
          pcall(vim.lsp.semantic_tokens.stop, bufnr, client.id)
        end

        -- show diagnostic popup for violations on hover
        vim.api.nvim_create_autocmd('CursorHold', {
          buffer = bufnr,
          callback = function()
            vim.diagnostic.open_float(nil, { focusable = false })
          end,
        })
      end,
    })

    vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = 'rounded',
    })

    vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
      border = 'rounded',
    })

    vim.diagnostic.config {
      -- we disable virtual_text by default, it's annoying
      virtual_text = false,
      update_in_insert = true,
      underline = true,
      severity_sort = true,
      float = {
        focusable = false,
        style = 'minimal',
        border = 'rounded',
        source = 'always',
        header = '',
        prefix = '',
      },
    }
  end,
}
