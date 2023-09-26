return {
  'folke/neodev.nvim',
  {
    'Mofiqul/vscode.nvim',
    config = function()
      vim.cmd('colorscheme vscode')
    end
  },
  -- LSP
  {
    'VonHeikemen/lsp-zero.nvim',
    dependencies = {
      -- LSP Support
      { 'neovim/nvim-lspconfig' },
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },

      -- Autocompletion
      { 'hrsh7th/nvim-cmp' },
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-path' },
      { 'saadparwaiz1/cmp_luasnip' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-nvim-lua' },
      { 'hrsh7th/vscode-langservers-extracted' },
      { 'rafamadriz/friendly-snippets' },
      { 'ray-x/lsp_signature.nvim' },

      -- Snippets
      { 'L3MON4D3/LuaSnip' },
      { 'rafamadriz/friendly-snippets' },
    }
  },

  -- Telescope
  'nvim-telescope/telescope-fzy-native.nvim',
  'nvim-lua/popup.nvim',

  -- Treesitter
  'nvim-treesitter/nvim-treesitter-context',
  'p00f/nvim-ts-rainbow',
  'JoosepAlviste/nvim-ts-context-commentstring',
  'lewis6991/impatient.nvim',
  'theprimeagen/harpoon',
  'mbbill/undotree',
  -- 'tpope/vim-surround',
  {
    'kylechui/nvim-surround',
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end
  },
  {
    'max397574/better-escape.nvim',
    lazy = false,
  },
  'mfussenegger/nvim-lint',
  {
    'onsails/lspkind-nvim',
    config = function()
      require("lspkind").init({
        symbol_map = {
          Copilot = "",
        },
      })
    end
  },
  'olimorris/neotest-rspec',
  'vim-test/vim-test',
  'mfussenegger/nvim-dap',
  {
    'leoluz/nvim-dap-go',
    ft = "go",
    dependencies = "mfussenegger/nvim-dap",
    config = function(_, opts)
      require("dap-go").setup(opts)
    end,
  },
  {
    "olexsmir/gopher.nvim",
    ft = "go",
    config = function(_, opts)
      require("gopher").setup(opts)
    end,
    build = function()
      vim.cmd [[silent! GoInstallDeps]]
    end,
  },
  'tpope/vim-dadbod',
  'norcalli/nvim-colorizer.lua',
  'christoomey/vim-tmux-runner',
  'm-novikov/tree-sitter-sql',
  'nanotee/sqls.nvim',
  {
    'tyru/open-browser-github.vim',
    lazy = false,
    dependencies = {
      'tyru/open-browser.vim'
    }
  },
  {
    'ethanholz/nvim-lastplace',
    lazy = false,
    config = function()
      require('nvim-lastplace').setup()
    end
  },
  -- {
  --   "zbirenbaum/copilot.lua",
  --   cmd = "Copilot",
  --   event = "InsertEnter",
  --   config = function()
  --     require("copilot").setup({
  --       suggestion = { enabled = false },
  --       panel = { enabled = false },
  --     })
  --   end,
  -- },
  -- {
  --   "zbirenbaum/copilot-cmp",
  --   after = { "copilot.lua" },
  --   config = function()
  --     require("copilot_cmp").setup()
  --   end,
  -- },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require('gitsigns').setup()
    end
  },
  {
    "windwp/nvim-autopairs"
  },
  {
    "windwp/nvim-ts-autotag"
  },
}
