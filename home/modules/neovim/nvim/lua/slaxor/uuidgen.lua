function GenerateUUID()
    math.randomseed(os.time())
    local random = math.random
    local template = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    return string.gsub(template, "x", function()
      local v = random(0, 0xf)  -- v is a decimal number 0 to 15
      return string.format("%x", v) --formatted as a hex number
    end)
  end

local insert_uuid = function()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local uuid = GenerateUUID()
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { uuid })
end

vim.keymap.set('i', '<leader>u', insert_uuid, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>u', insert_uuid, { noremap = true, silent = true })
