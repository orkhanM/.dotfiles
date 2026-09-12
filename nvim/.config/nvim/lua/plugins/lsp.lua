return {
  'williamboman/mason-lspconfig.nvim',
  dependencies = {
    -- lsp package manager
    'williamboman/mason.nvim',
    -- lsp client configurations
    'neovim/nvim-lspconfig',
    -- install non lsp mason packages
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    -- auto completion
    -- 'hrsh7th/cmp-nvim-lsp',
    -- 'hrsh7th/cmp-buffer',
    -- 'hrsh7th/cmp-path',
    -- 'hrsh7th/cmp-cmdline',
    -- 'hrsh7th/nvim-cmp',
    -- snippets engine (for cmp)
    -- 'L3MON4D3/LuaSnip',
    -- 'saadparwaiz1/cmp_luasnip',
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
        -- 'deno',
        'ts_ls',
      },
    }

    -- install lsp packages via mason-lspconfig
    require('mason-lspconfig').setup {
      -- Available servers:
      -- https://github.com/williamboman/mason-lspconfig.nvim?tab=readme-ov-file#available-lsp-servers
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
      handlers = {
        function(server_name)
          -- Use an on_attach function to only map the following keys
          -- after the language server attaches to the current buffer
          local on_attach_common = function(client, bufnr)
            -- dont overwrite vim formatting with LSP
            -- so things like gq keep working as normal
            -- https://github.com/jose-elias-alvarez/null-ls.nvim/issues/1131
            --vim.bo[bufnr].formatexpr = nil

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
            -- from dep above
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
            client.server_capabilities.semanticTokensProvider = nil
            pcall(vim.lsp.semantic_tokens.stop, bufnr, client.id)

            -- show diagnostic popup for violations on hover
            vim.api.nvim_create_autocmd('CursorHold', {
              buffer = bufnr,
              callback = function()
                vim.diagnostic.open_float(nil, { focusable = false })
              end,
            })
          end

          local lspconfig = require 'lspconfig'
          -- local capabilities = vim.lsp.protocol.make_client_capabilities()
          local capabilities = require('blink.cmp').get_lsp_capabilities()

          capabilities.textDocument.foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true,
          }

          -- LSP Configurations:
          --
          -- see: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#marksman
          lspconfig.lua_ls.setup {
            capabilities = capabilities,
            on_attach = on_attach_common,
            on_init = function(client)
              if client.workspace_folders then
                local path = client.workspace_folders[1].name
                if
                  path ~= vim.fn.stdpath 'config'
                  and (vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc'))
                then
                  return
                end
              end

              client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                runtime = {
                  -- Tell the language server which version of Lua you're using
                  -- (most likely LuaJIT in the case of Neovim)
                  version = 'LuaJIT',
                },
                -- Make the server aware of Neovim runtime files
                workspace = {
                  checkThirdParty = false,
                  library = {
                    vim.env.VIMRUNTIME,
                    -- Depending on the usage, you might want to add additional paths here.
                    '${3rd}/luv/library',
                    -- "${3rd}/busted/library",
                  },
                  -- or pull in all of 'runtimepath'. nOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
                  -- library = vim.api.nvim_get_runtime_file("", true)
                },
              })
            end,
            settings = {
              Lua = {},
            },
          }

          lspconfig.ts_ls.setup {
            capabilities = capabilities,
            on_attach = on_attach_common,
          }
          -- lspconfig.denols.setup {
          --   capabilities = capabilities,
          --   on_attach = on_attach_common,
          -- }

          -- YAMLLS See:
          --      https://github.com/redhat-developer/yaml-language-server#language-server-settings
          lspconfig.yamlls.setup {
            capabilities = capabilities,
            on_attach = on_attach_common,
            settings = {
              yaml = {
                -- https://github.com/redhat-developer/yaml-language-server/pull/962
                -- autoDetectKubernetesSchema = true,
                schemaStore = {
                  enable = true,
                },
                hover = {
                  enable = true,
                },
                -- getem from https://www.schemastore.org/json/
                schemas = {
                  -- argo workflows
                  --['https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json'] = '/*.yaml',
                  -- k8s resources
                  --['kubernetes'] = '/*.yaml',
                },
              },
            },
          }

          lspconfig.helm_ls.setup {
            capabilities = capabilities,
            on_attach = on_attach_common,
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
                    -- any other config from https://github.com/redhat-developer/yaml-language-server#language-server-settings
                  },
                },
              },
            },
          }

          lspconfig.gopls.setup {
            capabilities = capabilities,
            on_attach = on_attach_common,
          }

          lspconfig.golangci_lint_ls.setup {
            capabilities = capabilities,
            on_attach = on_attach_common,
          }

          -- rustfmt/clippy/rust-src come from rustup (see `make rust`), not mason
          lspconfig.rust_analyzer.setup {
            capabilities = capabilities,
            on_attach = on_attach_common,
            settings = {
              ['rust-analyzer'] = {
                checkOnSave = true,
                check = {
                  command = 'clippy',
                },
                procMacro = {
                  enable = true,
                },
              },
            },
          }

          lspconfig.pyright.setup {
            capabilities = capabilities,
            on_attach = on_attach_common,
            before_init = function(_, config)
              -- Function to find Python executable
              local function get_python_path()
                -- Try Poetry first
                local poetry_env = vim.fn.trim(vim.fn.system 'poetry env info --path 2>/dev/null')
                if vim.v.shell_error == 0 and poetry_env ~= '' then
                  return poetry_env .. '/bin/python'
                end
                --
                -- Try local .venv
                local venv = vim.fn.getcwd() .. '/.venv'
                if vim.fn.isdirectory(venv) == 1 then
                  return venv .. '/bin/python'
                end

                -- Try pipenv
                local pipenv = vim.fn.trim(vim.fn.system 'pipenv --venv 2>/dev/null')
                if vim.v.shell_error == 0 and pipenv ~= '' then
                  return pipenv .. '/bin/python'
                end

                -- Fallback to system python
                return vim.fn.exepath 'python3' or vim.fn.exepath 'python' or 'python'
              end

              config.settings = config.settings or {}
              config.settings.python = config.settings.python or {}
              config.settings.python.pythonPath = get_python_path()

              -- Also set venv path for Pyright to find installed packages
              local venv_path = vim.fn.trim(vim.fn.system 'poetry env info --path 2>/dev/null')
              if vim.v.shell_error == 0 and venv_path ~= '' then
                config.settings.python.venvPath = vim.fn.fnamemodify(venv_path, ':h')
                config.settings.python.venv = vim.fn.fnamemodify(venv_path, ':t')
              end
            end,
          }

          lspconfig.ansiblels.setup {
            capabilities = capabilities,
            on_attach = on_attach_common,
            settings = {
              ansible = {
                ansible = {
                  path = 'ansible', -- Path to ansible executable
                },
                executionEnvironment = {
                  enabled = false,
                },
                python = {
                  interpreterPath = 'python3', -- Path to python
                },
                validation = {
                  enabled = true,
                  lint = {
                    enabled = true,
                    path = 'ansible-lint', -- Path to ansible-lint
                  },
                },
              },
            },
            filetypes = { 'yaml.ansible', 'ansible' },
          }
          -- This ensures YAML files are properly detected as Ansible files
          vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
            pattern = { '*/playbooks/*.yml', '*/roles/*.yml', '*/tasks/*.yml', 'playbook.yml', '*/ansible/*.yml' },
            callback = function()
              vim.bo.filetype = 'yaml.ansible'
            end,
          })

          -- Configure terraform-ls
          lspconfig.terraformls.setup {
            -- Server settings
            cmd = { 'terraform-ls', 'serve' },
            filetypes = { 'terraform', 'terraform-vars', 'tf', 'tfvars', 'hcl' },
            capabilities = capabilities,
            on_attach = on_attach_common,

            -- LSP settings
            settings = {
              terraform = {
                -- Set your preferred terraform settings here
                -- For example:
                terraform = {
                  path = 'terraform',
                },
                -- Enable logging for debugging if needed (comment out in production)
                -- logFile = "/tmp/terraform-ls.log",
              },
            },
          }

          lspconfig.bashls.setup {
            --
            capabilities = capabilities,
            filetypes = { 'sh', 'bash', 'zsh' },
            on_attach = on_attach_common,
            settings = {
              globPattern = '**/*@(.sh|.zsh|.inc|.bash|.command)',
            },
          }

          lspconfig[server_name].setup {
            capabilities = capabilities,
            on_attach = on_attach_common,
          }
        end,
      },
    }

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

    -- local cmp = require 'cmp'
    -- cmp.setup {
    --   preselect = cmp.PreselectMode.None,
    --   snippet = {
    --     -- REQUIRED - you must specify a snippet engine
    --     expand = function(args)
    --       require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    --     end,
    --   },
    --   mapping = cmp.mapping.preset.insert {
    --     ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    --     ['<C-f>'] = cmp.mapping.scroll_docs(4),
    --     ['<C-Space>'] = cmp.mapping.complete(),
    --     ['<C-e>'] = cmp.mapping.abort(),
    --     ['<CR>'] = cmp.mapping.confirm { select = false }, -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    --   },
    --   sources = cmp.config.sources({
    --     { name = 'nvim_lsp' },
    --     { name = 'luasnip' },
    --   }, {
    --     { name = 'buffer' },
    --   }),
    -- }
  end,
}
