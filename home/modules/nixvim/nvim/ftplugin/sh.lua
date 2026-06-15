vim.api.nvim_buf_create_user_command(0, 'ConvertVar', function()
  vim.cmd([[%s/\v\$(\w+)/\${\1}/g]])
end, {})

vim.api.nvim_buf_create_user_command(0, 'SplitLongCmd', function()
  vim.cmd([[s/ \-/ \\\r    -/g]])
end, {})

local function apply_diff(lines, diff)
  local hunks, hunk = {}, nil

  for line in (diff .. "\n"):gmatch("([^\n]*)\n") do
    local old_start = line:match("^@@ %-(%d+),?%d* %+%d+,?%d* @@")
    if old_start then
      hunk = { start = tonumber(old_start), lines = {} }
      hunks[#hunks + 1] = hunk
    elseif hunk and line:match("^[ +%-]") then
      hunk.lines[#hunk.lines + 1] = line
    end
  end

  if #hunks == 0 then return lines end

  local out, src = {}, 1
  for _, h in ipairs(hunks) do
    while src < h.start do
      out[#out + 1] = lines[src]; src = src + 1
    end
    for _, hl in ipairs(h.lines) do
      local op, content = hl:sub(1, 1), hl:sub(2)
      if op == " " then
        out[#out + 1] = content; src = src + 1
      elseif op == "+" then
        out[#out + 1] = content
      elseif op == "-" then
        src = src + 1
      end
    end
  end
  while src <= #lines do
    out[#out + 1] = lines[src]; src = src + 1
  end

  return out
end

local function shellcheck_fix()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local diff = vim.fn.system("shellcheck -f diff -", table.concat(lines, "\n") .. "\n")
  if diff == "" then return end
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, apply_diff(lines, diff))
end

vim.keymap.set("n", "<leader>sc", shellcheck_fix, { desc = "shellcheck fix" })
vim.api.nvim_create_autocmd("BufWritePre", {
  buffer = 0,
  callback = shellcheck_fix,
})
