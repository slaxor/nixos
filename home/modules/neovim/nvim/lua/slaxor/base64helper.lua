local ns_id = vim.api.nvim_create_namespace("base64helpers")
local function get_recursive_decode()
  local node = vim.treesitter.get_node()
  if not node then return nil end
  local target = node
  if node:type() == "pair" then
    target = node:field("value")[1]
  elseif node:parent() and node:parent():type() == "pair" then
    target = node:parent():field("value")[1]
  end

  if not target then return nil end

  local raw = vim.treesitter.get_node_text(target, 0)
  local current = raw:gsub('["\']', ''):gsub('%s+', '')

  if #current < 4 or not current:match("^[A-Za-z0-9%+/=]+$") then return nil end

  local iteration = 0
  local result = ""
  while iteration < 5 do
    local decoded = vim.fn.system("echo " .. vim.fn.shellescape(current) .. " | base64 -d 2>/dev/null")
    if vim.v.shell_error ~= 0 or #decoded == 0 or decoded:find('[^\20-\126\10\13]') then
      break
    end
    result = decoded
    current = decoded:gsub('%s+', '')
    iteration = iteration + 1
    if not current:match("^[A-Za-z0-9%+/=]+$") then break end
  end
  if iteration > 0 then
    local row = target:range()
    return result, iteration, row
  end

  return nil
end

vim.api.nvim_create_autocmd({ "CursorMoved", "InsertLeave" }, {
  pattern = { "*.yaml", "*.yml", "*.json" },
  callback = function()
    vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)

    vim.schedule(function()
      local decoded, depth, row = get_recursive_decode()
      if decoded and row then
        local preview = decoded:gsub("\n", " "):gsub("%s+", " "):sub(1, 40)
        -- Double icon if recursive
        local icon = depth > 1 and "󰒃 󰒃 " or "󰒃 "

        vim.api.nvim_buf_set_extmark(0, ns_id, row, 0, {
          virt_text = { { " " .. icon .. preview .. "...", "Comment" } },
          virt_text_pos = 'eol',
        })
      end
    end)
  end,
})

vim.keymap.set('n', '<leader>y', function()
  local decoded, depth, _ = get_recursive_decode()
  if not decoded then
    vim.notify("No Base64 detected", vim.log.levels.WARN)
    return
  end

  vim.fn.setreg('+', decoded)

  local lines = vim.split(decoded, "\n")
  if lines[#lines] == "" then table.remove(lines) end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local width = 0
  for _, s in ipairs(lines) do width = math.max(width, #s) end

  vim.api.nvim_open_win(buf, true, {
    relative = 'cursor',
    row = 1,
    col = 0,
    width = math.min(width + 2, 80),
    height = math.min(#lines, 15),
    style = 'minimal',
    border = 'rounded',
    title = string.format(" Decoded %dx (Yanked) ", depth),
    title_pos = "center"
  })

  if lines[1]:match("^{") or lines[1]:match("^%[") then
    vim.bo[buf].filetype = "json"
  end

  vim.keymap.set('n', 'q', ':close<CR>', { buffer = buf })
  vim.keymap.set('n', '<Esc>', ':close<CR>', { buffer = buf })
end, { desc = "Recursive B64 Decode & Yank" })

local function k8s_encode_base64()
  local mode = vim.api.nvim_get_mode().mode
  local text, range
  local bufnr = vim.api.nvim_get_current_buf()

  if mode:match("[vV]") then
    local s_pos = vim.fn.getpos("v")
    local e_pos = vim.fn.getpos(".")
    local srow, scol = s_pos[2], s_pos[3]
    local erow, ecol = e_pos[2], e_pos[3]
    if srow > erow or (srow == erow and scol > ecol) then
      srow, erow, scol, ecol = erow, srow, ecol, scol
    end

    if mode == "V" then
      scol = 1
      ecol = #vim.api.nvim_buf_get_lines(bufnr, erow - 1, erow, false)[1]
    end
    range = { srow - 1, scol - 1, erow - 1, ecol }
    local lines = vim.api.nvim_buf_get_text(bufnr, range[1], range[2], range[3], range[4], {})
    text = table.concat(lines, "\n")
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
  else
    local node = vim.treesitter.get_node()
    if not node then return end

    local target = node
    if node:type() == "pair" then
      target = node:field("value")[1]
    elseif node:parent() and node:parent():type() == "pair" then
      target = node:parent():field("value")[1]
    end

    if not target then
      vim.notify("No value found to encode", vim.log.levels.WARN)
      return
    end

    local sr, sc, er, ec = target:range()
    range = { sr, sc, er, ec }
    text = vim.treesitter.get_node_text(target, 0):gsub('["\']', '')
  end

  if not text or #text == 0 then return end

  local encoded = vim.fn.system("echo -n " .. vim.fn.shellescape(text) .. " | base64 -w0")
  if vim.v.shell_error == 0 then
    vim.api.nvim_buf_set_text(bufnr, range[1], range[2], range[3], range[4], { encoded })
    vim.notify("Encoded to Base64 (w0)")
  else
    vim.notify("Encoding failed", vim.log.levels.ERROR)
  end
end

vim.keymap.set({ 'n', 'v' }, '<leader>x', k8s_encode_base64, { desc = "Base64 Encode (Smart/Visual)" })
