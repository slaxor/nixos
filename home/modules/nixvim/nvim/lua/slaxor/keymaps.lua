local M = {}

function M.comment_toggle()
  local api = require("Comment.api")
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
    vim.api.nvim_feedkeys(esc, "nx", false)
    api.toggle.linewise(vim.fn.visualmode())
  else
    api.toggle.linewise.current()
    vim.cmd("normal! j")
  end
end

function M.tab_expand()
  local ls = require("luasnip")
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
  end
end

function M.tab_jump_back()
  local ls = require("luasnip")
  if ls.jumpable(-1) then
    ls.jump(-1)
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<S-Tab>", true, false, true), "n", false)
  end
end

return M
