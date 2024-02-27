return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")

    -- REQUIRED
    harpoon:setup({})
    -- REQUIRED

    vim.keymap.set("n", ";a", function()
      harpoon:list():append()
    end)
    vim.keymap.set("n", ";e", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end)

    vim.keymap.set("n", ";1", function()
      harpoon:list():select(1)
    end)
    vim.keymap.set("n", ";2", function()
      harpoon:list():select(2)
    end)
    vim.keymap.set("n", ";3", function()
      harpoon:list():select(3)
    end)
    vim.keymap.set("n", ";4", function()
      harpoon:list():select(4)
    end)

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set("n", ";p", function()
      harpoon:list():prev()
    end)
    vim.keymap.set("n", ";n", function()
      harpoon:list():next()
    end)
  end,
}
