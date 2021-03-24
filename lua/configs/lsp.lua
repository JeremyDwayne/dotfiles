local on_attach = require'completion'.on_attach
require'lspconfig'.pyls.setup{ on_attach=on_attach }
require'lspconfig'.gopls.setup{ on_attach=on_attach }
require'lspconfig'.solargraph.setup{ on_attach=on_attach }
