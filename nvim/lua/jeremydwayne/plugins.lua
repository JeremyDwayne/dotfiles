local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    return
end

-- Have packer use a popup window
packer.init({
    display = {
        open_fn = function()
            return require("packer.util").float({ border = "rounded" })
        end,
    },
})

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'
    use 'folke/neodev.nvim'
    use {
        'Mofiqul/dracula.nvim',
        as = 'dracula',
        config = function()
            vim.cmd('colorscheme dracula')
        end
    }

    -- LSP
    use {
        'VonHeikemen/lsp-zero.nvim',
        requires = {
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
    }
    use 'glepnir/lspsaga.nvim'

    -- Telescope
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.0',
        -- or                          , branch = '0.1.x',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }
    use 'nvim-telescope/telescope-fzy-native.nvim'
    use { 'axkirillov/easypick.nvim', requires = 'nvim-telescope/telescope.nvim' }
    use 'nvim-lua/popup.nvim'

    -- Treesitter
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
    }
    use 'nvim-treesitter/playground'
    use 'nvim-treesitter/nvim-treesitter-textobjects'
    use 'JoosepAlviste/nvim-ts-context-commentstring'

    use 'lewis6991/impatient.nvim'
    use 'theprimeagen/harpoon'
    use 'mbbill/undotree'

    -- GIT
    use 'APZelos/blamer.nvim'
    use 'lewis6991/gitsigns.nvim'
    use 'rhysd/committia.vim'

    -- THE POPE
    use 'tpope/vim-fugitive'
    use 'tpope/vim-rhubarb'
    use 'tpope/vim-surround'
    use 'tpope/vim-vinegar'

    use 'windwp/nvim-autopairs'
    use 'windwp/nvim-ts-autotag'
    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    }
    use 'danymat/neogen'
    use 'max397574/better-escape.nvim'
    use 'akinsho/toggleterm.nvim'
    use 'mfussenegger/nvim-lint'
    use 'pwntester/octo.nvim'
    use {
        'nvim-tree/nvim-tree.lua',
        requires = {
            'nvim-tree/nvim-web-devicons',
        },
        tag = 'nightly'
    }
    use 'p00f/nvim-ts-rainbow'
    use {'akinsho/bufferline.nvim', tag = "v3.*", requires = 'nvim-tree/nvim-web-devicons'}
    use 'hoob3rt/lualine.nvim'
    use 'folke/trouble.nvim'
    use 'folke/lsp-colors.nvim'
    use 'onsails/lspkind-nvim'
    use 'lukas-reineke/indent-blankline.nvim'
    use 'marko-cerovac/material.nvim'
    use 'ThePrimeagen/refactoring.nvim'
    use {
        "nvim-neotest/neotest",
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "antoinemadec/FixCursorHold.nvim"
        }
    }
    use 'nvim-neotest/neotest-vim-test'
    use 'olimorris/neotest-rspec'
    use 'vim-test/vim-test'
    use 'mfussenegger/nvim-dap'
    use 'tpope/vim-dadbod'
    use 'kristijanhusak/vim-dadbod-completion'
    use 'kristijanhusak/vim-dadbod-ui'
    use 'norcalli/nvim-colorizer.lua'
    use 'christoomey/vim-tmux-runner'
    use 'm-novikov/tree-sitter-sql'
    use 'nanotee/sqls.nvim'
    use 'tyru/open-browser.vim'
    use 'tyru/open-browser-github.vim'
    use 'xiyaowong/nvim-transparent'

    -- Automatically set up your configuration
    if packer_bootstrap then
        require("packer").sync()
    end
end)
