return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = {
        "stylua",
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
        "json-lsp",
        "lua-language-server",
        "luacheck",
        "standardrb",
        "yaml-language-server",
        "html-lsp",
        "htmx-lsp",
        "templ",
      }
    end,
  },
}
