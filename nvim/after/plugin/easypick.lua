local status, easypick = pcall(require, "easypick")
if not status then return end

-- only required for the example to work
local base_branch = "main"

easypick.setup({
    pickers = {
        -- add your custom pickers here
        -- below you can find some examples of what those can look like

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

-- Maps
vim.keymap.set('n', '<leader>gc', '<cmd>Easypick changed_files<cr>')
vim.keymap.set('n', '<leader>gf', '<cmd>Easypick conflicts<cr>')
