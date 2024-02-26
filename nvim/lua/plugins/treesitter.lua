return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "RRethy/nvim-treesitter-endwise",
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = {
        "lua",
        "astro",
        "cmake",
        "cpp",
        "css",
        "gitignore",
        "go",
        "graphql",
        "http",
        "java",
        "php",
        "ruby",
        "regex",
        "scss",
        "sql",
        "svelte",
        "typescript",
        "javascript",
        "tsx",
        "json",
        "jsonc",
        "bash",
        "query",
        "markdown",
      },
      endwise = {
        enable = true,
      },
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)

      -- vim.filetype.add({
      --   extension = {
      --     mdx = "markdown",
      --   },
      -- })
      -- vim.treesitter.language.register("markdown", "mdx")
    end,
  },
}
