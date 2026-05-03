vim.api.nvim_buf_create_user_command(0, 'ConvertVar', function()
  vim.cmd([[%s/\v\$(\w+)/\${\1}/g]])
end, {})

vim.api.nvim_buf_create_user_command(0, 'SplitLongCmd', function()
  vim.cmd([[s/ \-/ \\\r    -/g]])
end, {})

