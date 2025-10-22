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

local function stripWhitespace(top, bottom)
  -- Only do if the buffer is modifiable
  -- and modified and we are at the tip of an undo tree
  if not (vim.bo.modifiable and vim.bo.modified and atTipOfUndo()) then
    return
  end

  if not top then return end

  -- All conditions passed, go ahead and strip
  -- Handle the user deleting lines at the bottom
  local file_bottom = vim.api.line('$')

  if top > file_bottom then
    -- The user deleted all the lines; there is nothing to do
    return
  end

  vim.b.bottom = math.min(file_bottom, bottom)

  -- Keep the cursor position and these marks:
  local original_cursor = vim.api.getcurpos()
  local first_changed = vim.api.getpos("'[")
  local last_changed = vim.api.getpos("']")

  vim.cmd("silent exe "..top.." ',' "..vim.b.bottom.. " 's/\\v\\s+$//e'")

  vim.api.setpos("']", last_changed)
  vim.api.setpos("'[", first_changed)
  vim.api.setpos('.', original_cursor)
end

vim.api.nvim_create_user_command("RmTrS", function()
       stripWhitespace()
end, { nargs = "+", complete = "command" })


-- function! ReadPart(file, start, end)
--   put =readfile(a:file)[a:start-1:a:end-1]
-- endfunction
-- "command! -nargs=+ Rp call ReadPart(<f-args>)
--
--  Restore cursor position, window position, and last search after running a
--  command.
-- "function! Preserve(command)
--    Save the last search.
--   "let search = @/
--    Save the current cursor position.
--   "let cursor_position = getpos('.')
--    Save the current window position.
--   "normal! H
--   "let window_position = getpos('.')
--   "call setpos('.', cursor_position)
--    Execute the command.
--   "execute a:command
--    Restore the last search.
--   "let @/ = search
--    Restore the previous window position.
--   "call setpos('.', window_position)
--   "normal! zt
--    Restore the previous cursor position.
--   "call setpos('.', cursor_position)
-- "endfunction
--
-- "function! CatchEXOutput(cmd)
--   "redir => message
--   "silent execute a:cmd
--   "redir END
--   "if empty(message)
--     "echoerr "no output"
--   "else
--     "enew
--      setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodified
--     "silent put=message
--   "endif
-- "endfunction
-- "command! -nargs=+ -complete=command CatchEXOutput call CatchEXOutput(<q-args>)
--
-- "function! ClangCheckImpl(cmd)
--   "if &autowrite | wall | endif
--   "echo "Running " . a:cmd . " ..."
--   "let l:output = system(a:cmd)
--   "cexpr l:output
--   "cwindow
--   "let w:quickfix_title = a:cmd
--   "if v:shell_error != 0
--     "cc
--   "endif
--   "let g:clang_check_last_cmd = a:cmd
-- "endfunction
--
-- "function! ClangCheck()
--   "let l:filename = expand('%')
--   "if l:filename =~ '\.\(cpp\|cxx\|cc\|c\)$'
--     "call ClangCheckImpl("clang-check " . l:filename)
--   "elseif exists("g:clang_check_last_cmd")
--     "call ClangCheckImpl(g:clang_check_last_cmd)
--   "else
--     "echo "Can't detect file's compilation arguments and no previous clang-check invocation!"
--   "endif
-- "endfunction
