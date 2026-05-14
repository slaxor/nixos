vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2command! -nargs=0 YAMLSanitize %!gojq --yaml-input --yaml-output '.'

-- vim.api.nvim_create_augroup("sql", { clear = true })

-- vim.api.nvim_create_autocmd("BufWritePre", {
  -- group = "sql",
  -- pattern = { "*.sql", "*.psql" },
  -- command = "whatever",
-- })

