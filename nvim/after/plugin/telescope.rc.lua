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
      width = 0.98,
      preview_cutoff = 120,
      preview_width = 0.6,
    },
  },
  extensions = { fzy_native = { override_generic_sorter = false, override_file_sorter = true } }
}

require('telescope').load_extension('fzy_native')

function _G.search_dotfiles()
  require("telescope.builtin").find_files({ prompt_title = "Dotfiles", cwd = "~/.dotfiles", find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden' } })
end
