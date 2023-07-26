return {
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    lazy = true,
    config = function()
      -- This is where you modify the settings for lsp-zero
      -- Note: autocompletion settings will not take effect

      require('lsp-zero.settings').preset({})
      local status, lsp = pcall(require, "lsp-zero")
      if not status then
        return
      end

      lsp.preset({
        name = "minimal",
        set_lsp_keymaps = true,
        manage_nvim_cmp = true,
        suggest_lsp_servers = true,
      })

      lsp.ensure_installed({
        "tsserver",
        "eslint",
        "lua_ls",
        "solargraph",
        "clangd",
        "gopls",
        "tailwindcss"
      })

      lsp.set_preferences({})

      vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
        vim.lsp.diagnostic.on_publish_diagnostics, {
          underline = true,
          update_in_insert = false,
          virtual_text = { spacing = 4, prefix = "●" },
          severity_sort = true,
        }
      )

      -- Diagnostic symbols in the sign column (gutter)
      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      vim.diagnostic.config({
        virtual_text = {
          prefix = '●'
        },
        update_in_insert = true,
        float = {
          source = "always", -- Or "if_many"
        },
      })


      lsp.set_preferences({
        sign_icons = {
          "", -- Text
          "", -- Method
          "", -- Function
          "", -- Constructor
          "", -- Field
          "", -- Variable
          "", -- Class
          "ﰮ", -- Interface
          "", -- Module
          "", -- Property
          "", -- Unit
          "", -- Value
          "", -- Enum
          "", -- Keyword
          "﬌", -- Snippet
          "", -- Color
          "", -- File
          "", -- Reference
          "", -- Folder
          "", -- EnumMember
          "", -- Constant
          "", -- Struct
          "", -- Event
          "ﬦ", -- Operator
          "", -- TypeParameter
        },
      })

      lsp.on_attach(function(_, bufnr)
        local opts = { buffer = bufnr, remap = false }
        lsp.default_keymaps({ buffer = bufnr })
        vim.keymap.set("n", "<leader>fm", function()
          vim.lsp.buf.format({ async = true })
        end, opts)
      end)

      -- Format on save
      vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]
    end
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      { 'L3MON4D3/LuaSnip' },
    },
    config = function()
      -- Here is where you configure the autocompletion settings.
      -- The arguments for .extend() have the same shape as `manage_nvim_cmp`:
      -- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#manage_nvim_cmp

      require('lsp-zero.cmp').extend()

      -- And you can configure cmp even more, if you want to.
      local cmp = require('cmp')
      local cmp_select = { behavior = cmp.SelectBehavior.Select }
      -- local cmp_action = require('lsp-zero.cmp').action()

      cmp.setup({
        mapping = {
          ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
          ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
          ["<C-e>"] = cmp.mapping.close(),
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
          }),
          ["<C-y>"] = cmp.mapping(
            cmp.mapping.confirm({
              behavior = cmp.ConfirmBehavior.Insert,
              select = true,
            }),
            { "i", "c" }
          ),
          ["<M-y>"] = cmp.mapping(
            cmp.mapping.confirm({
              behavior = cmp.ConfirmBehavior.Replace,
              select = false,
            }),
            { "i", "c" }
          ),
          ["<C-leader>"] = cmp.mapping({
            i = cmp.mapping.complete(),
            c = function(
              _ --[[fallback]]
            )
              if cmp.visible() then
                if not cmp.confirm({ select = true }) then
                  return
                end
              else
                cmp.complete()
              end
            end,
          }),
        }
      })
    end
  },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    cmd = 'LspInfo',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'williamboman/mason-lspconfig.nvim' },
      {
        'williamboman/mason.nvim',
        build = function()
          pcall(vim.cmd, 'MasonUpdate')
        end,
      },
    },
    config = function()
      -- This is where all the LSP shenanigans will live

      local lsp = require('lsp-zero')

      lsp.on_attach(function(_, bufnr)
        -- see :help lsp-zero-keybindings
        -- to learn the available actions
        lsp.default_keymaps({ buffer = bufnr })
      end)

      -- (Optional) Configure lua language server for neovim
      lsp.configure("tsserver", {
        cmd = { "typescript-language-server", "--stdio" },
        filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
        settings = {
          preferences = {
            importModuleSpecifierPreference = 'relative',
            importModuleSpecifierEnding = 'minimal',
          }
        }
      })

      lsp.configure("lua_ls", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities()),
        settings = {
          Lua = {
            format = {
              enable = true,
              defaultConfig = {
                indent_style = "space",
                indent_size = "2",
              },
            },
            runtime = {
              -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
              version = "LuaJIT",
              -- Setup your lua path
              path = vim.split(package.path, ";"),
            },
            diagnostics = {
              -- Get the language server to recognize the `vim` global
              globals = { "vim" },
            },
            workspace = {
              -- Make the server aware of Neovim runtime files
              library = {
                [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
              },
            },
          },
        },
      })

      lsp.configure("solargraph", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities()),
        cmd = { "solargraph", "stdio" },
        filetypes = { "ruby" },
        -- root_dir = util.root_pattern("Gemfile", ".git"),
        init_options = {
          formatting = true,
        },
        settings = {
          solargraph = {
            diagnostics = true,
          },
        },
        handlers = {
          ["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
            -- Disable virtual_text on file load
            -- Show with vim.lsp.diagnostic.show_line_diagnostics()
            virtual_text = false,
          }),
        },
        workspace = {
          primetrust = {
            [vim.fn.expand("$HOME/work/prime_trust_api")] = true,
            [vim.fn.expand("$HOME/work/prime_trust_front_end")] = true,
          },
        },
      })

      local util = require("lspconfig.util")
      lsp.configure("gopls", {
        cmd = { "gopls" },
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
        root_dir = util.root_pattern("go.mod", "go.work", ".git"),
        settings = {
          gopls = {
            completeUnimported = true,
            usePlaceholders = true,
            analyses = {
              unusedparams = true,
            }
          }
        }
      })

      lsp.setup()
    end
  }
}
