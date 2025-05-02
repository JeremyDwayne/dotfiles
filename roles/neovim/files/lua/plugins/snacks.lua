return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    lazygit = { enabled = true },
  },
  keys = {
    {
      "<leader>gg",
      function()
        Snacks.lazygit()
      end,
      desc = "Lazygit",
    },
  },
}
