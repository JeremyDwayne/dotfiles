return {
  "weizheheng/ror.nvim",
  dependencies = {
    "rcarriga/nvim-notify",
    "stevearc/dressing.nvim",
  },
  config = function()
    require("dressing").setup({
      input = {
        min_width = { 60, 0.9 },
      },
      select = {
        -- telescope = require('telescope.themes').get_ivy({...})
        telescope = require("telescope.themes").get_dropdown({ layout_config = { height = 15, width = 90 } }),
      },
    })

    -- The default settings
    require("ror").setup({
      test = {
        message = {
          -- These are the default title for nvim-notify
          file = "Running test file...",
          line = "Running single test...",
        },
        coverage = {
          -- To customize replace with the hex color you want for the highlight
          -- guibg=#354a39
          up = "DiffAdd",
          -- guibg=#4a3536
          down = "DiffDelete",
        },
        notification = {
          -- Using timeout false will replace the progress notification window
          -- Otherwise, the progress and the result will be a different notification window
          timeout = false,
        },
        pass_icon = "✅",
        fail_icon = "❌",
      },
    })

    -- Load the snippets
    require("luasnip.loaders.from_vscode").lazy_load()

    -- Set a keybind
    -- This "list_commands()" will show a list of all the available commands to run
    vim.keymap.set("n", "<Leader>rc", ":lua require('ror.commands').list_commands()<CR>", { silent = false })
  end,
}
