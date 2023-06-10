local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")

-- if you just want default config for the servers then put them in a table
local servers = { "lua_ls", "html", "cssls", "tsserver", "clangd", "solargraph" }

for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup({
		on_attach = on_attach,
		capabilities = capabilities,
	})
end

-- lspkind.lua
local lspkind = require("lspkind")
lspkind.init({
	symbol_map = {
		Copilot = "",
	},
})

vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
