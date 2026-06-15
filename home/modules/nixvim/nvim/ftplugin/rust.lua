vim.g.rustfmt_autosave = 1
-- vim.g.syntastic_rust_checkers = ['cargo']
vim.g.rust_use_custom_ctags_defs = 1
vim.g.rust_bang_comment_leader = 1
vim.g.rustc_makeprg_no_percent = 1
-- vim.g.rust_conceal = 1
-- vim.g.rust_conceal_mod_path = 1
-- vim.g.rust_conceal_pub = 1
vim.g.rust_recommended_style = 0
vim.g.rust_fold = 1
-- let g:rust_fold = 1

local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set(
  "n",
  "<leader>a",
  function()
    vim.cmd.RustLsp('codeAction') -- supports rust-analyzer's grouping
    -- or vim.lsp.buf.codeAction() if you don't want grouping.
  end,
  { silent = true, buffer = bufnr }
)
vim.keymap.set(
  "n",
  "K", -- Override Neovim's built-in hover keymap with rustaceanvim's hover actions
  function()
    vim.cmd.RustLsp({ 'hover', 'actions' })
  end,
  { silent = true, buffer = bufnr }
)
