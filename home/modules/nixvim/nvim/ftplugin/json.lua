vim.api.nvim_buf_create_user_command(0, 'JSONCheck', function()
  -- Using vim.cmd because running complex regex subs via Lua API is verbose
  vim.cmd([[!gojq '.' %]])
end, {})

vim.api.nvim_buf_create_user_command(0, 'JSONSanitize ', function()
  -- Using vim.cmd because running complex regex subs via Lua API is verbose
  vim.cmd([[%!gojq '.']])
end, {})

vim.api.nvim_buf_create_user_command(0, 'JSONTOYAML', function()
  local new_filename = vim.fn.expand('%:p:r') .. ".yaml"
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local input = table.concat(lines, "\n")
  local output = vim.fn.system("gojq --yaml-output '.'", input)
  vim.cmd('edit ' .. new_filename)
  local new_buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, vim.split(output, "\n"))
  vim.bo[new_buf].filetype = 'yaml'
  local ok, err = pcall(vim.api.nvim_buf_set_name, new_buf, new_filename)
  if not ok then
    print("Buffer created, but could not rename (file might already be open): " .. err)
  end
end, {})

