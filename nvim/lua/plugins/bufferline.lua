return {
  'akinsho/bufferline.nvim',
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    local groups = require('bufferline.groups')

    require('bufferline').setup({
      options = {
        numbers = "none", -- | "ordinal" | "buffer_id" | "both" | function({ ordinal, id, lower, raise }): string,
        close_command = "bd! %d", -- can be a string | function, see "Mouse actions"
        left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
        right_mouse_command = 'vert sbuffer %d',
        middle_mouse_command = nil, -- can be a string | function, see "Mouse actions"
        sort_by = 'insert_after_current',
        buffer_close_icon = "",
        -- buffer_close_icon = '',
        modified_icon = "●",
        close_icon = "",
        -- close_icon = '',
        left_trunc_marker = "",
        right_trunc_marker = "",
        max_name_length = 30,
        max_prefix_length = 30, -- prefix used when a buffer is de-duplicated
        diagnostics = "nvim_lsp", -- | "nvim_lsp" | "coc",
        diagnostics_update_in_insert = false,
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
          local s = " "
          for e, n in pairs(diagnostics_dict) do
            local sym = e == "error" and " " or (e == "warning" and " " or "")
            s = s .. n .. sym
          end
          return s
        end,
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
        -- can also be a table containing 2 custom separators
        -- [focused and unfocused]. eg: { '|', '|' }
        separator_style = "thin", -- | "thick" | "thin" | "slant" | "padded_slant" | "slope" | { 'any', 'any' },
        enforce_regular_tabs = true,
        always_show_bufferline = true,
        hover = { enabled = true, reveal = { 'close' } },
        offsets = {
          {
            text = 'EXPLORER',
            filetype = 'neo-tree',
            highlight = 'PanelHeading',
            text_align = 'left',
            separator = true,
          },
          {
            text = ' FLUTTER OUTLINE',
            filetype = 'flutterToolsOutline',
            highlight = 'PanelHeading',
            separator = true,
          },
          {
            text = 'UNDOTREE',
            filetype = 'undotree',
            highlight = 'PanelHeading',
            separator = true,
          },
          {
            text = ' DATABASE VIEWER',
            filetype = 'dbui',
            highlight = 'PanelHeading',
            separator = true,
          },
          {
            text = ' DIFF VIEW',
            filetype = 'DiffviewFiles',
            highlight = 'PanelHeading',
            separator = true,
          },
        },
        groups = {
          options = { toggle_hidden_on_enter = true },
          items = {
            groups.builtin.pinned:with({ icon = '' }),
            groups.builtin.ungrouped,
            {
              name = 'Dependencies',
              icon = '',
              highlight = { fg = '#ECBE7B' },
              matcher = function(buf) return vim.startswith(buf.path, vim.env.VIMRUNTIME) end,
            },
            {
              name = 'Terraform',
              matcher = function(buf) return buf.name:match('%.tf') ~= nil end,
            },
            {
              name = 'Kubernetes',
              matcher = function(buf) return buf.name:match('kubernetes') and buf.name:match('%.yaml') end,
            },
            {
              name = 'SQL',
              matcher = function(buf) return buf.filename:match('%.sql$') end,
            },
            {
              name = 'tests',
              icon = '',
              matcher = function(buf)
                local name = buf.filename
                if name:match('%.sql$') == nil then return false end
                return name:match('_spec') or name:match('_test')
              end,
            },
            {
              name = 'docs',
              icon = '',
              matcher = function(buf)
                if vim.bo[buf.id].filetype == 'man' or buf.path:match('man://') then return true end
                for _, ext in ipairs({ 'md', 'txt', 'org', 'norg', 'wiki' }) do
                  if ext == vim.fn.fnamemodify(buf.path, ':e') then return true end
                end
              end,
            },
          },
        }
      }
    })
  end
}
