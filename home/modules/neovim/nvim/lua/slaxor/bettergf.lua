vim.api.nvim_create_augroup("mkdir_on_save", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  group = "mkdir_on_save",
  pattern = "*",
  callback = function()
    local dir = vim.fn.expand("%:p:h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.system("mkdir -p " .. dir)
    end
  end
})

vim.api.nvim_set_keymap('n', 'gf', ':lua CreateFileIfMissing()<CR>', { noremap = true, silent = true })

function CreateFileIfMissing()
  local file = vim.fn.expand("<cfile>")
  local dir = vim.fn.expand("<cfile>:h")
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.system("mkdir -p " .. dir)
  end
  if vim.fn.filereadable(file) == 0 then
    vim.fn.writefile({}, file)
  end
  vim.cmd("edit " .. file)
end

