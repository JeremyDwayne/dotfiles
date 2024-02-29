return {
  "michaelrommel/nvim-silicon",
  lazy = true,
  cmd = "Silicon",
  config = function()
    require("silicon").setup({
      -- Configuration here, or leave empty to use defaults
      font = "Dank Mono=34;Noto Color Emoji=34",
      theme = "Dracula",
      background = "#94e2d5",
      window_title = function()
        return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()), ":t")
      end,
      to_clipboard = true,
    })
  end,
}
