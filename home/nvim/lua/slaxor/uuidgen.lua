--[[ Your uuid function global and renamed for example --]]
function Generate_uuid()
    math.randomseed(os.time())
    local random = math.random
    local template = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    return string.gsub(template, "x", function()
      local v = random(0, 0xf)  -- v is a decimal number 0 to 15
      return string.format("%x", v) --formatted as a hex number
    end)
  end

--[[ Generate a uuid and place it at current cursor position --]]
local insert_uuid = function()
    -- Get row and column cursor,
    -- use unpack because it's a tuple.
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local uuid = Generate_uuid()
    -- Notice the uuid is given as an array parameter, you can pass multiple strings.
    -- Params 2-5 are for start and end of row and columns.
    -- See earlier docs for param clarification or `:help nvim_buf_set_text.
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { uuid })
end

-- Finally we map this somewhere to the key and mode we want.
-- i stands for insert mode next set the insert_uuid without invoking it.
-- For the last parameter see `:help map-arguments`  and adjust accordingly.
vim.keymap.set('i', '<leader>\\', insert_uuid, { noremap = true, silent = true })
