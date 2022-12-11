local nvim_lsp = require('lspconfig')
local protocol = require 'vim.lsp.protocol'
local lsp_configs = require('lspconfig.configs')
local util = require 'lspconfig.util'

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', 'C-f', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', 'C-j', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  --protocol.SymbolKind = { }
  protocol.CompletionItemKind = {
    '', -- Text
    '', -- Method
    '', -- Function
    '', -- Constructor
    '', -- Field
    '', -- Variable
    '', -- Class
    'ﰮ', -- Interface
    '', -- Module
    '', -- Property
    '', -- Unit
    '', -- Value
    '', -- Enum
    '', -- Keyword
    '﬌', -- Snippet
    '', -- Color
    '', -- File
    '', -- Reference
    '', -- Folder
    '', -- EnumMember
    '', -- Constant
    '', -- Struct
    '', -- Event
    'ﬦ', -- Operator
    '', -- TypeParameter
  }

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

vim.lsp.set_log_level("debug")
local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}


-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'pyright', 'rust_analyzer' }
for _, lsp in pairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities()),
    flags = lsp_flags,
  }
end

lsp_configs.prosemd = {
  default_config = {
    cmd = { "prosemd-lsp", "--stdio" },
    filetypes = { "markdown" },
    root_dir = function(fname)
      return util.find_git_ancestor(fname) or vim.fn.getcwd()
    end,
    settings = {},
  }
}

nvim_lsp.prosemd.setup { on_attach = on_attach }

nvim_lsp.intelephense.setup {
  on_attach = on_attach,
  settings = {
    diagnostic = {
      checkCurrentLine = true,
      errorSign = "✘",
      warningSign = "",
      infoSign = "",
    },
    intelephense = {
      telemetry = { enabled = false },
      completion = {
        triggerParameterHints = true,
        insertUseDeclaration = true,
        fullyQualifyGlobalConstantsAndFunctions = true,
      },
      trace = { server = "messages" },
      stubs = {
        "apache",
        "bcmath",
        "bz2",
        "calendar",
        "com_dotnet",
        "Core",
        "ctype",
        "curl",
        "date",
        "dba",
        "dom",
        "enchant",
        "exif",
        "FFI",
        "fileinfo",
        "filter",
        "fpm",
        "ftp",
        "gd",
        "gettext",
        "gmp",
        "hash",
        "iconv",
        "imap",
        "intl",
        "json",
        "ldap",
        "libxml",
        "mbstring",
        "meta",
        "mysqli",
        "oci8",
        "odbc",
        "openssl",
        "pcntl",
        "pcre",
        "PDO",
        "pdo_ibm",
        "pdo_mysql",
        "pdo_pgsql",
        "pdo_sqlite",
        "pgsql",
        "Phar",
        "posix",
        "pspell",
        "readline",
        "Reflection",
        "session",
        "shmop",
        "SimpleXML",
        "snmp",
        "soap",
        "sockets",
        "sodium",
        "SPL",
        "sqlite3",
        "standard",
        "superglobals",
        "sysvmsg",
        "sysvsem",
        "sysvshm",
        "tidy",
        "tokenizer",
        "xml",
        "xmlreader",
        "xmlrpc",
        "xmlwriter",
        "xsl",
        "Zend OPcache",
        "zip",
        "zlib",
        "wordpress"
      }
    }
  }
}

nvim_lsp.solargraph.setup {
  on_attach = on_attach,
  capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities()),
  cmd = { "solargraph", "stdio" },
  filetypes = { "ruby" },
  root_dir = util.root_pattern("Gemfile", ".git"),
  flags = lsp_flags,
  init_options = {
    formatting = true
  },
  settings = {
    solargraph = {
      diagnostics = true,
    }
  },
  handlers = {
    ["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {
      -- Disable virtual_text on file load
      -- Show with vim.lsp.diagnostic.show_line_diagnostics()
      virtual_text = false
    }
    ),
  },
  workspace = {
    primetrust = { [vim.fn.expand('$HOME/work/prime_trust_api')] = true,
      [vim.fn.expand('$HOME/work/prime_trust_front_end')] = true }
  },
}

nvim_lsp.tsserver.setup {
  on_attach = on_attach,
  filetypes = { "typescript", "typescriptreact", "typescript.tsx", "javascript" },
  capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
}

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- nvim_lsp.diagnosticls.setup {
--   on_attach = on_attach,
--   capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities()),
--   init_options = {
--     linters = {
--       rubocop = {
--         command = "exec rubocop",
--         sourceName = "rubocop",
--         debounce = 100,
--         args = {
--           "--format",
--           "json",
--           "--force-exclusion",
--           "%filepath"
--         },
--         parseJson = {
--           errorsRoot = "files[0].offenses",
--           line = "location.line",
--           column = "location.column",
--           message = "[${cop_name}] ${message}",
--           security = "severity"
--         },
--         securities = {
--           [2] = "error",
--           [1] = "warning"
--         }
--       }
--     },
--     eslint = {
--       command = 'eslint_d',
--       rootPatterns = { '.git' },
--       debounce = 100,
--       args = { '--stdin', '--stdin-filename', '%filepath', '--format', 'json' },
--       sourceName = 'eslint_d',
--       parseJson = {
--         errorsRoot = '[0].messages',
--         line = 'line',
--         column = 'column',
--         endLine = 'endLine',
--         endColumn = 'endColumn',
--         message = '[eslint] ${message} [${ruleId}]',
--         security = 'severity'
--       },
--       securities = {
--         [2] = 'error',
--         [1] = 'warning'
--       }
--     },
--   },
--   filetypes = {
--     javascript = 'eslint',
--     javascriptreact = 'eslint',
--     typescript = 'eslint',
--     typescriptreact = 'eslint',
--   },
--   formatters = {
--     eslint_d = {
--       command = 'eslint_d',
--       args = { '--stdin', '--stdin-filename', '%filename', '--fix-to-stdout' },
--       rootPatterns = { '.git' },
--     },
--     prettier = {
--       command = 'prettier',
--       args = { '--stdin-filepath', '%filename' }
--     }
--   },
--   formatFiletypes = {
--     css = 'prettier',
--     javascript = 'eslint_d',
--     javascriptreact = 'eslint_d',
--     json = 'jq',
--     scss = 'prettier',
--     less = 'prettier',
--     typescript = 'eslint_d',
--     typescriptreact = 'eslint_d',
--     markdown = 'prettier',
--   }
-- }

-- icon
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
  underline = true,
  -- This sets the spacing and the prefix, obviously.
  virtual_text = {
    spacing = 4,
    prefix = ''
  }
}
)

nvim_lsp.sumneko_lua.setup {
  on_attach = on_attach,
  capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities()),
  settings = {
    Lua = {
      format = {
        enable = true,
        defaultConfig = {
          indent_style = "space",
          indent_size = "2",
        }
      },
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Setup your lua path
        path = vim.split(package.path, ';')
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { 'vim' }
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = { [vim.fn.expand('$VIMRUNTIME/lua')] = true, [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true }
      }
    }
  }
}

nvim_lsp.jsonls.setup {
  on_attach = on_attach,
  capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities()),
  init_options = {
    provideFormatter = true,
  },
  formatCommand = "jq"
}

-- require("lspconfig").clangd.setup {
--     on_attach = on_attach
-- }
