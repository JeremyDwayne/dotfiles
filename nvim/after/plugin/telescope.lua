local builtin = require('telescope.builtin')
-- Maps
vim.keymap.set('n', ';f', builtin.find_files)
vim.keymap.set('n', ';p', builtin.git_files)
vim.keymap.set('n', ';d', ':lua search_dotfiles()<cr>')
vim.keymap.set('n', ';r', builtin.live_grep)
vim.keymap.set('n', '\\', builtin.buffers)
vim.keymap.set('n', ';;', builtin.help_tags)
vim.keymap.set('n', '//', builtin.current_buffer_fuzzy_find)
vim.keymap.set('n', '<leader>ps', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)
vim.keymap.set('n', '<leader>km', builtin.keymaps)

local actions = require('telescope.actions')
-- Global remapping

require('telescope').setup {
    defaults = {
        file_sorter = require('telescope.sorters').get_fzy_sorter,
        color_devicons = true,

        file_previewer = require('telescope.previewers').vim_buffer_cat.new,
        grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
        qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
        mappings = { n = { ["q"] = actions.close } },
        layout_config = {
            width = 100,
            height = 100,
            preview_width = 0.65,
        },
    },
    pickers = {
        find_files = {
            layout_config = {
                width = 80,
            },
        },
        live_grep = {
            layout_config = {
                width = 80,
            },
        }
    },
    extensions = { fzy_native = { override_generic_sorter = false, override_file_sorter = true } }
}

require('telescope').load_extension('fzy_native')
require("telescope").load_extension('harpoon')

function _G.search_dotfiles()
    require("telescope.builtin").find_files({ prompt_title = "Dotfiles", cwd = "~/.dotfiles",
        find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden' } })
end
