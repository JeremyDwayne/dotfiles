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

local util = require("lspconfig.util")
local lspkind = require("lspkind")
local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }
cmp.setup({
  formatting = {
    format = lspkind.cmp_format({
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
    }),
  },
  sorting = {
    priority_weight = 1.0,
    comparators = {
      cmp.config.compare.score,
      cmp.config.compare.locality,
      cmp.config.compare.offset,
      cmp.config.compare.exact,

      function(entry1, entry2)
        local _, entry1_under = entry1.completion_item.label:find("^_+")
        local _, entry2_under = entry2.completion_item.label:find("^_+")
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
    },
  },
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
})

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

local cmp_mappings = lsp.defaults.cmp_mappings({
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
})

lsp.setup_nvim_cmp({
  mapping = cmp_mappings,
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

lsp.setup()
