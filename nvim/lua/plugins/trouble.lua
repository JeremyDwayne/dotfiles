return {
  "folke/trouble.nvim",
  keys = {
    {
      "<leader>tt",
      function()
        require("trouble").toggle()
      end,
      desc = "Toggle Trouble",
    },
    {
      "<leader>tn",
      function()
        require("trouble").next({ skip_groups = true, jump = true })
      end,
      desc = "Toggle Next",
    },
    {
      "<leader>tn",
      function()
        require("trouble").previous({ skip_groups = true, jump = true })
      end,
      desc = "Toggle Previous",
    },
  },
}
