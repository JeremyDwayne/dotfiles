return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "lua",
        "astro",
        "cmake",
        "cpp",
        "css",
        "fish",
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
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)

      vim.filetype.add({
        extension = {
          mdx = "markdown",
        },
      })
      vim.treesitter.language.register("markdown", "mdx")
    end,
  },
}
