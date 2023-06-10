local M = {}

M.treesitter = {
	ensure_installed = {
		"ruby",
		"typescript",
		"tsx",
		"bash",
		"vim",
		"lua",
		"html",
		"css",
		"javascript",
		"c",
		"markdown",
		"markdown_inline",
	},
	autopairs = {
		enable = true,
	},
	indent = {
		enable = true,
		-- disable = {
		--   "python"
		-- },
	},
	rainbow = {
		enable = true,
		extended_mode = true,
		max_file_lines = nil,
	},
}

M.mason = {
	ensure_installed = {
		-- lua stuff
		"lua-language-server",
		"stylua",

		-- web dev stuff
		"css-lsp",
		"html-lsp",
		"typescript-language-server",
		"deno",
		"prettier",
		"rubocop",
		"solargraph",
	},
}

-- git support in nvimtree
M.nvimtree = {
	git = {
		enable = true,
	},

	renderer = {
		highlight_git = true,
		icons = {
			show = {
				git = true,
			},
		},
	},
}

return M
