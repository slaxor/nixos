vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.listchars.tab = '-->'
vim.opt_local.list = true

-- vim.api.nvim_create_augroup("sql", { clear = true })

-- vim.api.nvim_create_autocmd("BufWritePre", {
-- group = "sql",
-- pattern = { "*.sql", "*.psql" },
-- command = "whatever",
-- })

-- :set listchars+=tab:-->
-- set list


vim.api.nvim_buf_create_user_command(0, 'YAMLCheck', function()
  vim.cmd([[!gojq --yaml-input --yaml-output '.' %]])
end, {})

vim.api.nvim_buf_create_user_command(0, 'YAMLSanitize ', function()
  vim.cmd([[%!gojq --yaml-input --yaml-output '.']])
end, {})

vim.api.nvim_buf_create_user_command(0, 'YAMLTOJSON', function()
  local new_filename = vim.fn.expand('%:p:r') .. ".json"
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local input = table.concat(lines, "\n")
  local output = vim.fn.system("gojq --yaml-input '.'", input)
  vim.cmd('edit ' .. new_filename)
  local new_buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, vim.split(output, "\n"))
  vim.bo[new_buf].filetype = 'json'
  local ok, err = pcall(vim.api.nvim_buf_set_name, new_buf, new_filename)
  if not ok then
    print("Buffer created, but could not rename (file might already be open): " .. err)
  end
end, {})
