local present, null_ls = pcall(require, "null-ls")

if not present then
	return
end

local b = null_ls.builtins

local sources = {
	-- formatting
	b.formatting.deno_fmt, -- choosed deno for ts/js files cuz its very fast!
	b.formatting.prettier.with({ filetypes = { "html", "markdown", "css", "json", "markdown", "scss" } }), -- so prettier works only on these filetypes
	b.formatting.stylua,
	b.formatting.clang_format,
	b.formatting.rubocop,

	-- diagnostics
	b.diagnostics.eslint_d.with({
		diagnostics_format = "[eslint] #{m}\n(#{c})",
	}),
	b.diagnostics.rubocop,
}

-- local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
--
-- null_ls.setup({
-- 	debug = true,
-- 	sources = sources,
-- 	on_attach = function(client, bufnr)
-- 		if client.supports_method("textDocument/formatting") then
-- 			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
-- 			vim.api.nvim_create_autocmd("BufWritePre", {
-- 				group = augroup,
-- 				buffer = bufnr,
-- 				callback = function()
-- 					vim.lsp.buf.format({ async = true })
-- 				end,
-- 			})
-- 		end
-- 	end,
-- })
