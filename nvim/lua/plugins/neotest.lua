return {
  "nvim-neotest/neotest",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "antoinemadec/FixCursorHold.nvim",
    'nvim-neotest/neotest-vim-test'
  },
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
        neotest.run.run({ vim.fn.expand("%:p"), env = get_env() })
      end,
      ["<leader>ns"] = function()
        for _, adapter_id in ipairs(neotest.run.adapters()) do
          neotest.run.run({ suite = true, adapter = adapter_id, env = get_env() })
        end
      end,
      ["<leader>nx"] = function()
        neotest.run.stop()
      end,
      ["<leader>nn"] = function()
        neotest.run.run({ env = get_env() })
      end,
      ["<leader>nd"] = function()
        neotest.run.run({ strategy = "dap", env = get_env() })
      end,
      ["<leader>nl"] = function()
        neotest.run.run_last()
      end,
      ["<leader>nD"] = function()
        neotest.run.run_last({ strategy = "dap" })
      end,
      ["<leader>na"] = function()
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
    }

    for keys, mapping in pairs(mappings) do
      vim.api.nvim_set_keymap("n", keys, "", { callback = mapping, noremap = true })
    end
    neotest.setup({
      log_level = vim.log.levels.WARN,
      -- discovery = {
      --   filter_dir = function(_, rel_path)
      --     return vim.startswith(rel_path, "tests")
      --   end,
      -- },
      status = {
        virtual_text = true,
        signs = true,
      },
      icons = {
        running_animated = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
      },
      strategies = {
        integrated = {
          width = 180,
        },
      },
      adapters = {
        -- require("neotest-python")({
        --   dap = { justMyCode = false, console = "integratedTerminal" },
        -- }),
        -- require("neotest-plenary"),
        require("neotest-rspec")({
          rspec_cmd = function()
            return vim.tbl_flatten({
              "bundle",
              "exec",
              "rspec",
            })
          end
        }),
        require("neotest-vim-test")({
          ignore_file_types = { "python", "vim", "lua" },
        }),
      },
    })
  end
}
