local function redir(cmd, rng, start_line, end_line)
  -- Close all scratch windows
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.w[win].scratch then
      vim.api.nvim_win_close(win, true)
    end
  end

  local output = {}
  if cmd:sub(1, 1) == '!' then
    -- Shell command
    local shell_cmd
    if cmd:find(' %%') then
      local file_path = vim.fn.expand('%:p')
      shell_cmd = cmd:gsub(' %%', ' ' .. vim.fn.shellescape(file_path))
      shell_cmd = shell_cmd:sub(2) -- Remove leading '!'
    else
      shell_cmd = cmd:sub(2)
    end

    if rng == 0 then
      output = vim.fn.systemlist(shell_cmd)
    else
      local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
      local joined_lines = table.concat(lines, '\n')
      -- Use echo with quoted string to pass to shell
      local cleaned_lines = vim.fn.shellescape(joined_lines)
      output = vim.fn.systemlist(shell_cmd .. " <<< $" .. cleaned_lines)
    end
  else
    -- Vim command
    output = vim.fn.split(vim.fn.execute(cmd), '\n')
  end

  -- Create a new scratch buffer
  vim.cmd('vnew')
  vim.b.scratch = true
  vim.bo.buftype = 'nofile'
  vim.bo.bufhidden = 'wipe'
  vim.bo.swapfile = false
  vim.bo.buflisted = false
  vim.api.nvim_buf_set_lines(0, 0, -1, false, output)
end

-- Create user commands
vim.api.nvim_create_user_command("Redir", function(opts)
  redir(opts.args, opts.range ~= 0, opts.line1, opts.line2)
end, {
  nargs = 1,
  complete = "command",
  range = true,
  bar = true
})

-- Alternative command (no -bar so double quotes work)
vim.api.nvim_create_user_command("RedirQ", function(opts)
  redir(opts.args, opts.range ~= 0, opts.line1, opts.line2)
end, {
  nargs = 1,
  complete = "command",
  range = true,
  bar = false
})
-- Command without -bar for double quotes in external commands (but can't chain commands)
vim.api.nvim_create_user_command('RedirNoBar', function(opts)
  redir(opts.args, opts.range, opts.line1, opts.line2)
end, {
  nargs = 1,
  complete = 'command',
  range = true,
})
