local overrides = require("custom.configs.overrides")

---@type NvPluginSpec[]
local plugins = {
	-- Disabled plugins
	--   set enabled = false
	{
		"folke/which-key.nvim",
		enabled = false,
	},

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
		lazy = false,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-neotest/neotest-vim-test",
		},
		config = function()
			require("custom.configs.neotest") -- just an example path
		end,
	},
	{ "olimorris/neotest-rspec" },
	{ "vim-test/vim-test" },
	{ "mfussenegger/nvim-dap" },
	{
		"tyru/open-browser-github.vim",
		lazy = false,
		dependencies = {
			"tyru/open-browser.vim",
		},
	},
	{ "xiyaowong/nvim-transparent" },
	{
		"ethanholz/nvim-lastplace",
		lazy = false,
		config = function()
			require("nvim-lastplace").setup()
		end,
	},
	{
		"github/copilot.vim",
		lazy = false,
	},
	{
		"christoomey/vim-tmux-navigator",
		lazy = false,
	},
}

return plugins
