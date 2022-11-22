-- Setup nvim-cmp.
local cmp = require 'cmp'
local lspkind = require('lspkind')
local neogen = require('neogen')

cmp.setup({
  formatting = {
    format = lspkind.cmp_format({ with_text = false, maxwidth = 50 })
  },
  snippet = {
    expand = function(args)
      -- For `vsnip` user.
      vim.fn["vsnip#anonymous"](args.body)

      -- For `luasnip` user.
      -- require('luasnip').lsp_expand(args.body)

      -- For `ultisnips` user.
      -- vim.fn["UltiSnips#Anon"](args.body)
    end,
  },
  mapping = {
    ["<tab>"] = cmp.mapping(function(fallback)
      if require('neogen').jumpable() then
        require('neogen').jump_next()
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),
    ["<S-tab>"] = cmp.mapping(function(fallback)
      if require('neogen').jumpable(true) then
        require('neogen').jump_prev()
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true
    }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'path' },
    { name = 'nvim_lua' },
    { name = 'buffer' },
  }
})

-- If you want insert `(` after select function or method item
-- local cmp_autopairs = require('nvim-autopairs.completion.cmp')
-- cmp.event:on( 'confirm_done', cmp_autopairs.on_confirm_done({  map_char = { tex = '' } }))

-- add a lisp filetype (wrap my-function), FYI: Hardcoded = { "clojure", "clojurescript", "fennel", "janet" }
-- cmp_autopairs.lisp[#cmp_autopairs.lisp+1] = "racket"
