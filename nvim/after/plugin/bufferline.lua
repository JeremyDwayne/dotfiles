local status, bufferline = pcall(require, "bufferline")
if not status then return end

bufferline.setup {
    options = {
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
            local s = " "
            for e, n in pairs(diagnostics_dict) do
                local sym = e == "error" and " " or (e == "warning" and " " or "")
                s = s .. n .. sym
            end
            return s
        end,
        show_buffer_close_icons = false,
        show_close_icon = false,
        name_formatter = function(buf) -- buf contains a "name", "path" and "bufnr"
            -- remove extension from markdown files for example
            if buf.name:match('%.md') then return vim.fn.fnamemodify(buf.name, ':t:r') end
        end,
    }
}
