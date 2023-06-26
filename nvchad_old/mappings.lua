---@type MappingsTable
local M = {}

M.general = {
	n = {
		["<C-h>"] = { "<cmd> TmuxNavigateLeft<CR>", "window left" },
		["<C-l>"] = { "<cmd> TmuxNavigateRight<CR>", "window right" },
		["<C-j>"] = { "<cmd> TmuxNavigateDown<CR>", "window down" },
		["<C-k>"] = { "<cmd> TmuxNavigateUp<CR>", "window up" },
		[";"] = { ":", "enter command mode", opts = { nowait = true } },
	},
}

M.tabufline = {
	n = {
		-- cycle through buffers
		["<S-l>"] = {
			function()
				require("nvchad_ui.tabufline").tabuflineNext()
			end,
			"goto next buffer",
		},

		["<S-h>"] = {
			function()
				require("nvchad_ui.tabufline").tabuflinePrev()
			end,
			"goto prev buffer",
		},
	},
}

M.trouble = {
	n = {
		["<leader>xx"] = { "<cmd>TroubleToggle<cr>", "Trouble Toggle" },
		["<leader>xw"] = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "Trouble Workspace Diagnostics" },
		["<leader>xd"] = { "<cmd>TroubleToggle document_diagnostics<cr>", "Trouble Document Diagnostics" },
		["<leader>xq"] = { "<cmd>TroubleToggle quickfix<cr>", "Trouble Quickfix List" },
		["<leader>xl"] = { "<cmd>TroubleToggle loclist<cr>", "Trouble Local List" },
		["<leader>xr"] = { "<cmd>TroubleToggle lsp_references<cr>", "Trouble LSP References" },
	},
}

M.telescope = {
	i = {
		["<C-q>"] = {
			function()
				require("trouble.providers.telescope").open_with_trouble()
			end,
			"Open with Trouble",
		},
	},
	n = {
		["<C-q>"] = {
			function()
				require("trouble.providers.telescope").open_with_trouble()
			end,
			"Open with Trouble",
		},
	},
}

M.disabled = {
	n = {
		["<Tab>"] = "",
		["<S-Tab>"] = "",
		["<leader>wK"] = "",
		["<leader>wk"] = "",
	},
	i = {
		["<Tab>"] = "",
		["<S-Tab>"] = "",
	},
}

-- more keybinds!

return M
