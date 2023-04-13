local overrides = require("custom.configs.overrides")

---@type NvPluginSpec[]
local plugins = {

	-- Override plugin definition options

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			-- format & linting
			{
				"jose-elias-alvarez/null-ls.nvim",
				config = function()
					require("custom.configs.null-ls")
				end,
			},
		},
		config = function()
			require("plugins.configs.lspconfig")
			require("custom.configs.lspconfig")
		end, -- Override to setup mason-lspconfig
	},

	-- override plugin configs
	{
		"williamboman/mason.nvim",
		opts = overrides.mason,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		opts = overrides.treesitter,
	},

	{
		"nvim-tree/nvim-tree.lua",
		opts = overrides.nvimtree,
	},

	-- Install a plugin
	{
		"max397574/better-escape.nvim",
		event = "InsertEnter",
		config = function()
			require("better_escape").setup()
		end,
	},

	-- To make a plugin not be loaded
	-- {
	--   "NvChad/nvim-colorizer.lua",
	--   enabled = false
	-- },
	{ "p00f/nvim-ts-rainbow" },
	{ "JoosepAlviste/nvim-ts-context-commentstring" },
	{ "lewis6991/impatient.nvim" },
	{ "mbbill/undotree" },
	{ "kylechui/nvim-surround" },
	{ "windwp/nvim-ts-autotag" },
	{ "max397574/better-escape.nvim" },
	{ "mfussenegger/nvim-lint" },
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-neotest/neotest-vim-test",
		},
	},
	{ "olimorris/neotest-rspec" },
	{ "vim-test/vim-test" },
	{ "mfussenegger/nvim-dap" },
	{
		"tyru/open-browser-github.vim",
		dependencies = {
			"tyru/open-browser.vim",
		},
	},
	{ "xiyaowong/nvim-transparent" },
	{
		"ethanholz/nvim-lastplace",
		config = function()
			require("nvim-lastplace").setup()
		end,
	},
	{
		"github/copilot.vim",
		lazy = false,
	},
}

return plugins
