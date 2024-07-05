return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = {
        "eslint-lsp",
        "stylua",
        "selene",
        "shellcheck",
        "shfmt",
        "tailwindcss-language-server",
        "typescript-language-server",
        "css-lsp",
        "docker-compose-language-service",
        "dockerfile-language-server",
        "gofumpt",
        "goimports",
        "gomodifytags",
        "gopls",
        "hadolint",
        "impl",
        "json-lsp",
        "lua-language-server",
        "luacheck",
        "prettier",
        "prettierd",
        "pyright",
        "ruff-lsp",
        -- "solargraph",
        -- "rubocop",
        "standardrb",
        "ruby-lsp",
        "taplo",
        "terraform-ls",
        "yaml-language-server",
        "java-language-server",
        "java-test",
        "html-lsp",
        "htmx-lsp",
        "templ",
      }
    end,
  },
}
