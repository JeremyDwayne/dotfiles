local base_branch = "main"

return {
  'axkirillov/easypick.nvim',
  keys = {
    { '<leader>gc', '<cmd>Easypick changed_files<cr>', desc = 'Git Changed Files' },
    { '<leader>gf', '<cmd>Easypick conflicts<cr>', desc = 'Merge Conflicts' },
  },
  config = function()
    local easypick = require('easypick')
    easypick.setup({
      pickers = {
        -- list files inside current folder with default previewer
        {
          -- name for your custom picker, that can be invoked using :Easypick <name> (supports tab completion)
          name = "ls",
          -- the command to execute, output has to be a list of plain text entries
          command = "ls",
          -- specify your custom previwer, or use one of the easypick.previewers
          previewer = easypick.previewers.default()
        },

        -- diff current branch with base_branch and show files that changed with respective diffs in preview
        {
          name = "changed_files",
          command = "git diff --name-only $(git merge-base HEAD origin/" .. base_branch .. " )",
          previewer = easypick.previewers.branch_diff({ base_branch = base_branch }),
          opts = require('telescope.themes').get_ivy({ layout_config = { height = 0.9 } })
        },

        -- list files that have conflicts with diffs in preview
        {
          name = "conflicts",
          command = "git diff --name-only --diff-filter=U --relative",
          previewer = easypick.previewers.file_diff(),
          opts = require('telescope.themes').get_ivy({ layout_config = { height = 0.9 } })
        }
      }

    })
  end
}
