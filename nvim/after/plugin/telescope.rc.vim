if !exists('g:loaded_telescope') | finish | endif

nnoremap <silent> ;f <cmd>Telescope find_files<cr>
nnoremap <C-p> <cmd>Telescope git_files<cr>
nnoremap <silent> ;r <cmd>Telescope live_grep<cr>
nnoremap <silent> \\ <cmd>Telescope buffers<cr>
nnoremap <silent> ;; <cmd>Telescope help_tags<cr>
nnoremap <leader>ed :lua search_dotfiles()<cr>

lua << EOF
local actions = require('telescope.actions')
-- Global remapping

require('telescope').setup{
  defaults = {
    file_sorter = require('telescope.sorters').get_fzy_sorter,
    color_devicons = true,

    file_previewer = require('telescope.previewers').vim_buffer_cat.new,
    grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
    qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
    mappings = {
      n = {
        ["q"] = actions.close
      },
    },
  },
  extensions = {
    override_generic_sorter = false,
    override_file_sorter = true,
  }
}

require('telescope').load_extension('fzy_native')

function _G.search_dotfiles()
  require("telescope.builtin").find_files({
    prompt_title = "~ Dotfiles ~",
    cwd = "~/.dotfiles",
    })
end

EOF
