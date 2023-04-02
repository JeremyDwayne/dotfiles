local status, lsp = pcall(require, "lsp-zero")
if not status then return end

lsp.preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = true,
})

lsp.ensure_installed({
  'tsserver',
  'eslint',
  'lua_ls',
  'solargraph'
})

lsp.set_preferences({})

local util = require("lspconfig.util")
local neogen = require('neogen')
local lspkind = require('lspkind')
local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
cmp.setup({
  formatting = {
    format = lspkind.cmp_format {
      with_text = true,
      menu = {
        buffer = "[buf]",
        nvim_lsp = "[LSP]",
        nvim_lua = "[api]",
        path = "[path]",
        luasnip = "[snip]",
        gh_issues = "[issues]",
        tn = "[TabNine]",
      },
    },
  },
  sorting = {
    priority_weight = 1.0,
    comparators = {
      cmp.config.compare.score,
      cmp.config.compare.locality,
      cmp.config.compare.offset,
      cmp.config.compare.exact,

      function(entry1, entry2)
        local _, entry1_under = entry1.completion_item.label:find "^_+"
        local _, entry2_under = entry2.completion_item.label:find "^_+"
        entry1_under = entry1_under or 0
        entry2_under = entry2_under or 0
        if entry1_under > entry2_under then
          return false
        elseif entry1_under < entry2_under then
          return true
        end
      end,

      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    }
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
})

local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-e>'] = cmp.mapping.close(),
  ['<CR>'] = cmp.mapping.confirm({
    behavior = cmp.ConfirmBehavior.Insert,
    select = true
  }),
  ["<C-y>"] = cmp.mapping(
    cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    },
    { "i", "c" }
  ),
  ["<M-y>"] = cmp.mapping(
    cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    },
    { "i", "c" }
  ),
  ["<C-leader>"] = cmp.mapping {
    i = cmp.mapping.complete(),
    c = function(
      _ --[[fallback]]
    )
      if cmp.visible() then
        if not cmp.confirm { select = true } then
          return
        end
      else
        cmp.complete()
      end
    end,
  },
})

lsp.setup_nvim_cmp({
  mapping = cmp_mappings
})

lsp.set_preferences({
  sign_icons = {
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
})

lsp.on_attach(function(_, bufnr)
  local opts = { buffer = bufnr, remap = false }
  lsp.default_keymaps({buffer = bufnr})
  -- vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end, opts)
  -- vim.keymap.set('n', 'gi', function() vim.lsp.buf.implementation() end, opts)
  -- vim.keymap.set('n', 'gr', function() vim.lsp.buf.references() end, opts)
  -- vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, opts)
  -- vim.keymap.set('i', '<C-h>', function() vim.lsp.buf.signature_help() end, opts)
  -- vim.keymap.set('n', '<leader>vws', function() vim.lsp.buf.workleader_symbol() end, opts)
  -- vim.keymap.set('n', '<leader>vd', function() vim.diagnostic.open_float() end, opts)
  -- vim.keymap.set('n', '<C-j>', function() vim.diagnostic.goto_next() end, opts)
  -- vim.keymap.set('n', '<C-f>', function() vim.diagnostic.goto_prev() end, opts)
  -- vim.keymap.set('n', '<leader>vca', function() vim.lsp.buf.code_action() end, opts)
  -- vim.keymap.set('n', '<leader>vtd', function() vim.lsp.buf.type_definition() end, opts)
  -- vim.keymap.set('n', '<leader>vrn', function() vim.lsp.buf.rename() end, opts)
  -- vim.keymap.set('n', '<leader>wa', function() vim.lsp.buf.add_workleader_folder() end, opts)
  -- vim.keymap.set('n', '<leader>wr', function() vim.lsp.buf.remove_workleader_folder() end, opts)
  -- vim.keymap.set('n', '<leader>wl', function()
  --   print(vim.inspect(vim.lsp.buf.list_workleader_folders()))
  -- end, opts)
  vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format({ async = true }) end, opts)
end)


lsp.configure('lua_ls', {
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
        library = { [vim.fn.expand('$VIMRUNTIME/lua')] = true,[vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true }
      }
    }
  }
})

lsp.configure('solargraph', {
  capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities()),
  cmd = { "solargraph", "stdio" },
  filetypes = { "ruby" },
  -- root_dir = util.root_pattern("Gemfile", ".git"),
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
    primetrust = {
      [vim.fn.expand('$HOME/work/prime_trust_api')] = true,
      [vim.fn.expand('$HOME/work/prime_trust_front_end')] = true
    }
  },
})


-- local enabled_features = {
--   "documentHighlights",
--   "documentSymbols",
--   "foldingRanges",
--   "selectionRanges",
--   "semanticHighlighting",
--   "formatting",
--   "codeActions",
-- }
--
-- lsp.configure('ruby_lsp', {
--   default_config = {
--     cmd = { "bundle", "exec", "ruby-lsp" },
--     filetypes = { "ruby" },
--     root_dir = util.root_pattern("Gemfile", ".git"),
--     init_options = {
--       enabledFeatures = enabled_features,
--     },
--     settings = {},
--   },
--   commands = {
--     FormatRuby = {
--       function()
--         vim.lsp.buf.format({
--           name = "ruby_lsp",
--           async = true,
--         })
--       end,
--       description = "Format using ruby-lsp",
--     },
--   },
-- })

lsp.setup()
