local bstatus, builtin = pcall(require, "telescope.builtin")
if (not bstatus) then return end
local astatus, actions = pcall(require, "telescope.actions")
if (not astatus) then return end

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

-- Global remapping
require('telescope').setup {
    defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        path_display = { "smart" },
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
    mappings = {
        i = {
            ["<C-n>"] = actions.cycle_history_next,
            ["<C-p>"] = actions.cycle_history_prev,

            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,

            ["<C-c>"] = actions.close,

            ["<Down>"] = actions.move_selection_next,
            ["<Up>"] = actions.move_selection_previous,

            ["<CR>"] = actions.select_default,
            ["<C-x>"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            ["<C-t>"] = actions.select_tab,

            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,

            ["<PageUp>"] = actions.results_scrolling_up,
            ["<PageDown>"] = actions.results_scrolling_down,

            ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
            ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<C-l>"] = actions.complete_tag,
            ["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
        },

        n = {
            ["<esc>"] = actions.close,
            ["<CR>"] = actions.select_default,
            ["<C-x>"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            ["<C-t>"] = actions.select_tab,

            ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
            ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

            ["j"] = actions.move_selection_next,
            ["k"] = actions.move_selection_previous,
            ["H"] = actions.move_to_top,
            ["M"] = actions.move_to_middle,
            ["L"] = actions.move_to_bottom,

            ["<Down>"] = actions.move_selection_next,
            ["<Up>"] = actions.move_selection_previous,
            ["gg"] = actions.move_to_top,
            ["G"] = actions.move_to_bottom,

            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,

            ["<PageUp>"] = actions.results_scrolling_up,
            ["<PageDown>"] = actions.results_scrolling_down,

            ["?"] = actions.which_key,
        },
    },
    pickers = {
        find_files = {
            theme = "ivy",
            layout_config = {
                height = 0.8,
            },
        },
        live_grep = {
            theme = "ivy",
            layout_config = {
                height = 0.8,
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
