return {
  "telescope.nvim",
  dependencies = { "nvim-telescope/telescope-file-browser.nvim" },
  keys = {
    {
      "<leader>fP",
      function()
        require("telescope.builtin").find_files({
          cwd = require("lazy.core.config").options.root,
        })
      end,
      desc = "Find Plugin File",
    },
    {
      "<leader>fo",
      function()
        require("telescope.builtin").oldfiles()
      end,
    },
    {
      ";f",
      function()
        local builtin = require("telescope.builtin")
        builtin.find_files({
          no_ignore = false,
          hidden = true,
        })
      end,
    },
    {
      ";r",
      function()
        local builtin = require("telescope.builtin")
        builtin.live_grep()
      end,
    },
    {
      "\\\\",
      function()
        local builtin = require("telescope.builtin")
        builtin.buffers()
      end,
    },
    {
      ";t",
      function()
        local builtin = require("telescope.builtin")
        builtin.help_tags()
      end,
    },
    {
      ";;",
      function()
        local builtin = require("telescope.builtin")
        builtin.resume()
      end,
    },
    {
      ";e",
      function()
        local builtin = require("telescope.builtin")
        builtin.diagnostics()
      end,
    },
    {
      ";s",
      function()
        local builtin = require("telescope.builtin")
        builtin.treesitter()
      end,
    },
    {
      ";k",
      function()
        local builtin = require("telescope.builtin")
        builtin.keymaps()
      end,
    },
    {
      "fb",
      function()
        local telescope = require("telescope")
        local function telescope_buffer_dir()
          return vim.fn.expand("%:p:h")
        end
        telescope.extensions.file_browser.file_browser({
          path = "%:p:h",
          cwd = telescope_buffer_dir(),
          respect_gitignore = false,
          hidden = true,
          grouped = true,
          previewer = false,
          initial_mode = "normal",
          layout_config = { height = 40 },
        })
      end,
    },
    -- {
    --   "gw",
    --   function()
    --     local telescope = require("telescope")
    --     telescope.extensions.git_worktree.git_worktrees()
    --     -- <Enter> - switches to that worktree
    --     -- <c-d> - deletes that worktree
    --     -- <c-f> - toggles forcing of the next deletion
    --   end,
    -- },
    -- {
    --   "gwc",
    --   function()
    --     local telescope = require("telescope")
    --     telescope.extensions.git_worktree.create_git_worktree()
    --   end,
    -- },
  },
  config = function(_, opts)
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local fb_actions = require("telescope").extensions.file_browser.actions

    -- opts.defaults = vim.tbl_deep_extend("force", opts.defaults, {
    --   wrap_results = true,
    --   layout_strategy = "horizontal",
    --   layout_config = { prompt_position = "top" },
    --   sorting_strategy = "ascending",
    --   winblend = 0,
    --   mappings = {
    --     n = {},
    --   },
    -- })

    opts.pickers = {
      diagnostics = {
        theme = "ivy",
        initial_mode = "normal",
        layout_config = { preview_cutoff = 9999 },
      },
    }

    opts.extensions = {
      file_browser = {
        theme = "dropdown",
        hijack_netrw = true,
        mappings = {
          ["n"] = {
            -- custom normal mode mappings
            ["a"] = fb_actions.create,
            ["h"] = fb_actions.goto_parent_dir,
            ["/"] = function()
              vim.cmd("startinsert")
            end,
            ["<C-u>"] = function(prompt_bufnr)
              for _ = 1, 10 do
                actions.move_selection_previous(prompt_bufnr)
              end
            end,
            ["<C-d>"] = function(prompt_bufnr)
              for _ = 1, 10 do
                actions.move_selection_next(prompt_bufnr)
              end
            end,
            ["<PageUp>"] = actions.preview_scrolling_up,
            ["<PageDown>"] = actions.preview_scrolling_down,
          },
        },
      },
    }
    telescope.setup(opts)
    -- require("telescope").load_extension("fzf")
    require("telescope").load_extension("file_browser")
    -- require("telescope").load_extension("git_worktree")
    -- require("telescope").load_extension("noice")
  end,
}
