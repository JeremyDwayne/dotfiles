return {
  "hkupty/nvimux",
  lazy = false,
  config = function()
    local nvimux = require('nvimux')
    nvimux.setup {
      config = {
        prefix = '<C-a>',
      },
      bindings = {
        { { 'n', 'v', 'i', 't' }, '-', nvimux.commands.horizontal_split },
        { { 'n', 'v', 'i', 't' }, '|', nvimux.commands.vertical_split },
        { { 'n', 'v', 'i', 't' }, 't', nvimux.commands.toggle_term },
      }
    }
  end
}
