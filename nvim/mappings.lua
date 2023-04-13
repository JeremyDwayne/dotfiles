---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
  },
}

M.tabufline = {
  n = {
    -- cycle through buffers
    ["<S-l>"] = {
      function()
        require("nvchad_ui.tabufline").tabuflineNext()
      end,
      "goto next buffer",
    },

    ["<S-h>"] = {
      function()
        require("nvchad_ui.tabufline").tabuflinePrev()
      end,
      "goto prev buffer",
    },
  },
}

M.disabled = {
  n = {
    ["<Tab>"] = "",
    ["<S-Tab>"] = "",
  },
  i = {
    ["<Tab>"] = "",
    ["<S-Tab>"] = "",
  }
}

-- more keybinds!

return M
