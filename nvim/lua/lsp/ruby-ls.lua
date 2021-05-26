-- If you are using rvm, make sure to change below configuration
require'lspconfig'.solargraph.setup {
    -- cmd = { DATA_PATH .. "~/.rvm/gems/ruby-3.0.0/bin/solargraph", "--stdio" },
    on_attach = require'lsp'.common_on_attach,
    handlers = {
        ["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
            virtual_text = O.ruby.diagnostics.virtual_text,
            signs = O.ruby.diagnostics.signs,
            underline = O.ruby.diagnostics.underline,
            update_in_insert = true

        })
    },
    filetypes = O.ruby.filetypes,
    -- root_dir = require'lspconfig'.util.root_pattern("Gemfile", ".git", "."),
    settings = {
        solargraph = {
            autoformat = true,
            completion = true,
            diagnostic = true,
            folding = true,
            references = true,
            rename = true,
            symbols = true
        }
    }
}
