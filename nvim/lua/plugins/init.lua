return {
  -- Packer can manage itself
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
  {
    "glepnir/lspsaga.nvim",
    event = "LspAttach",
    config = function()
      require("lspsaga").setup({})
    end,
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
      --Please make sure you install markdown and markdown_inline parser
      { "nvim-treesitter/nvim-treesitter" }
    }
  },

  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { { 'nvim-lua/plenary.nvim' } }
  },
  'nvim-telescope/telescope-fzy-native.nvim',
  { 'axkirillov/easypick.nvim', dependencies = 'nvim-telescope/telescope.nvim' },
  'nvim-lua/popup.nvim',

  -- Treesitter
  'nvim-treesitter/playground',
  'p00f/nvim-ts-rainbow',
  'JoosepAlviste/nvim-ts-context-commentstring',
  'lewis6991/impatient.nvim',
  'theprimeagen/harpoon',
  'mbbill/undotree',

  -- GIT
  'APZelos/blamer.nvim',
  'lewis6991/gitsigns.nvim',
  'rhysd/committia.vim',

  -- THE POPE
  'tpope/vim-rhubarb',
  'tpope/vim-surround',
  'tpope/vim-vinegar',
  'windwp/nvim-ts-autotag',
  'danymat/neogen',
  'max397574/better-escape.nvim',
  'akinsho/toggleterm.nvim',
  'mfussenegger/nvim-lint',
  'pwntester/octo.nvim',
  'hoob3rt/lualine.nvim',
  'folke/lsp-colors.nvim',
  'onsails/lspkind-nvim',
  'lukas-reineke/indent-blankline.nvim',
  'marko-cerovac/material.nvim',
  'ThePrimeagen/refactoring.nvim',
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim"
    }
  },
  'nvim-neotest/neotest-vim-test',
  'olimorris/neotest-rspec',
  'vim-test/vim-test',
  'mfussenegger/nvim-dap',
  'tpope/vim-dadbod',
  'kristijanhusak/vim-dadbod-completion',
  'kristijanhusak/vim-dadbod-ui',
  'norcalli/nvim-colorizer.lua',
  'christoomey/vim-tmux-runner',
  'm-novikov/tree-sitter-sql',
  'nanotee/sqls.nvim',
  {
    'tyru/open-browser-github.vim',
    dependencies = {
      'tyru/open-browser.vim'
    }
  },
  'xiyaowong/nvim-transparent',
  {
    'ethanholz/nvim-lastplace',
    config = function()
      require('nvim-lastplace').setup()
    end
  },
}
