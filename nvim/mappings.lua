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

M.disabled = {
	n = {
		["<Tab>"] = "",
		["<S-Tab>"] = "",
	},
	i = {
		["<Tab>"] = "",
		["<S-Tab>"] = "",
	},
}

-- more keybinds!

return M
