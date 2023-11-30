return {
  'lukas-reineke/indent-blankline.nvim',
  main = "ibl",
  config = {
    indent = {
      char = "▏",
    },
    exclude = {
      filetypes = {
        "help",
        "startify",
        "dashboard",
        "packer",
        "neogitstatus",
        "NvimTree",
        "Trouble",
      },
      buftypes = {
        "terminal",
        "nofile"
      },
    },
  },
}
