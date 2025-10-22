-- Disable inline virtual text (the "pseudo comments")
vim.diagnostic.config({
  virtual_text = false,  -- This disables the inline text
  signs = true,          -- Keep signs in the gutter
  underline = true,      -- Keep underline under errors
  update_in_insert = false,
})

-- Now setup trouble.nvim to show diagnostics
require('trouble').setup({
  auto_open = false,  -- Don't auto-open (or set to true if you want)
  auto_close = true,
})

-- Keymap to toggle trouble instead of seeing inline text
vim.keymap.set('n', '<leader>xx', '<cmd>TroubleToggle document_diagnostics<cr>', { desc = 'Toggle diagnostics (Trouble)' })
