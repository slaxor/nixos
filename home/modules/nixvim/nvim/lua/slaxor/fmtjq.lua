vim.api.nvim_create_user_command("Jq", function()
  local save_reg = vim.fn.getreg('"')
  local save_regtype = vim.fn.getregtype('"')
  vim.cmd('normal! gvy')
  local input = vim.fn.getreg('"')
  local output = vim.fn.system("gojq .", input)
  if vim.v.shell_error ~= 0 then
    vim.notify("gojq error: " .. output, vim.log.levels.ERROR)
    vim.fn.setreg('"', save_reg, save_regtype)
    return
  end
  vim.fn.setreg('"', output, 'v')
  vim.cmd('normal! gvp')
  vim.fn.setreg('"', save_reg, save_regtype)
end, { range = true, desc = "Format selection with gojq" })

vim.keymap.set("v", "<leader>j", ":Jq<CR>", { silent = true })
