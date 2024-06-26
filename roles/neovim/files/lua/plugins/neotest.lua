---@diagnostic disable: missing-fields
return {
  "nvim-neotest/neotest",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "antoinemadec/FixCursorHold.nvim",
    "olimorris/neotest-rspec",
    "nvim-neotest/neotest-go",
    "zidhuss/neotest-minitest",
    "nvim-neotest/nvim-nio",
    "nvim-neotest/neotest-jest",
  },
  -- keys = {
  --   {
  --     "<leader>tt",
  --     function() require("neotest").run.run(vim.fn.expand("%")) end,
  --     desc = "Run File"
  --   },
  --   {
  --     "<leader>tT",
  --     function() require("neotest").run.run(vim.loop.cwd()) end,
  --     desc = "Run All Test Files"
  --   },
  --   {
  --     "<leader>tr",
  --     function() require("neotest").run.run() end,
  --     desc = "Run Nearest"
  --   },
  --   {
  --     "<leader>ts",
  --     function() require("neotest").summary.toggle() end,
  --     desc = "Toggle Summary"
  --   },
  --   {
  --     "<leader>to",
  --     function() require("neotest").output.open({ enter = true, auto_close = true }) end,
  --     desc = "Show Output"
  --   },
  --   {
  --     "<leader>tO",
  --     function() require("neotest").output_panel.toggle() end,
  --     desc = "Toggle Output Panel"
  --   },
  --   {
  --     "<leader>tS",
  --     function() require("neotest").run.stop() end,
  --     desc = "Stop"
  --   },
  -- },
  config = function()
    local neotest = require("neotest")
    local lib = require("neotest.lib")
    local get_env = function()
      local env = {}
      local file = ".env"
      if not lib.files.exists(file) then
        return {}
      end

      for _, line in ipairs(vim.fn.readfile(file)) do
        for name, value in string.gmatch(line, "(%S+)=['\"]?(.*)['\"]?") do
          local str_end = string.sub(value, -1, -1)
          if str_end == "'" or str_end == '"' then
            value = string.sub(value, 1, -2)
          end

          env[name] = value
        end
      end
      return env
    end
    local group = vim.api.nvim_create_augroup("NeotestConfig", {})
    for _, ft in ipairs({ "output", "attach", "summary" }) do
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "neotest-" .. ft,
        group = group,
        callback = function(opts)
          vim.keymap.set("n", "q", function()
            pcall(vim.api.nvim_win_close, 0, true)
          end, {
            buffer = opts.buf,
          })
        end,
      })
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "neotest-output-panel",
      group = group,
      callback = function()
        vim.cmd("norm G")
      end,
    })

    local mappings = {
      ["<leader>nr"] = function()
        neotest.run.run({ suite = false, vim.fn.expand("%:p"), env = get_env() })
      end,
      ["<leader>ns"] = function()
        for _, adapter_id in ipairs(neotest.state.adapter_ids()) do
          neotest.run.run({ suite = true, adapter = adapter_id, env = get_env() })
        end
      end,
      ["<leader>nw"] = function()
        for _, adapter_id in ipairs(neotest.state.adapter_ids()) do
          neotest.watch.watch({ suite = true, adapter = adapter_id, env = get_env() })
        end
      end,
      ["<leader>nx"] = function()
        neotest.run.stop()
      end,
      ["<leader>nn"] = function()
        neotest.run.run({ suite = false, env = get_env() })
      end,
      ["<leader>nl"] = function()
        neotest.run.run_last()
      end,
      ["<leader>nA"] = function()
        neotest.run.attach()
      end,
      ["<leader>no"] = function()
        neotest.output.open({ enter = true, last_run = true })
      end,
      ["<leader>ni"] = function()
        neotest.output.open({ enter = true })
      end,
      ["<leader>nO"] = function()
        neotest.output.open({ enter = true, short = true })
      end,
      ["<leader>np"] = function()
        neotest.summary.toggle()
      end,
      ["<leader>nm"] = function()
        neotest.summary.run_marked()
      end,
      ["<leader>ne"] = function()
        neotest.output_panel.toggle()
      end,
      ["[n"] = function()
        neotest.jump.prev({ status = "failed" })
      end,
      ["]n"] = function()
        neotest.jump.next({ status = "failed" })
      end,
      ["<leader>jw"] = function()
        neotest.run.run({ jestCommand = "jest --watch " })
      end,
    }

    for keys, mapping in pairs(mappings) do
      vim.api.nvim_set_keymap("n", keys, "", { callback = mapping, noremap = true })
    end
    neotest.setup({
      status = {
        enabled = true,
        virtual_text = true,
        signs = true,
      },
      log_level = vim.log.levels.WARN,
      icons = {
        running_animated = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
      },
      strategies = {
        integrated = {
          width = 180,
        },
      },
      adapters = {
        require("neotest-rspec"),
        require("neotest-go"),
        require("neotest-minitest"),
        require("neotest-jest"),
      },
    })
  end,
}
