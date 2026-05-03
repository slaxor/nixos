vim.opt_local.expandtab = false
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2   -- Number of spaces a tab counts for while editing
vim.g.go_autodetect_gopath = 1
-- vim.g.go_fmt_command = "goimports" -- Uncomment if needed
vim.g.go_highlight_extra_types = 1
vim.g.go_highlight_fields = 1
vim.g.go_highlight_function_calls = 1
vim.g.go_highlight_functions = 1
vim.g.go_highlight_generate_tags = 1
vim.g.go_highlight_types = 1
vim.g.go_list_height = 0
vim.g.go_list_type = "quickfix"

local function build_go_files()
  local file = vim.fn.expand('%')
  -- Check if file ends in _test.go
  if file:match('_test%.go$') then
    vim.fn['go#test#Test'](0, 1)
  elseif file:match('%.go$') then
    vim.fn['go#cmd#Build'](0)
  end
end

local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, {
    buffer = true,  -- Only apply to this buffer (Go files)
    remap = true,   -- Required for <Plug> mappings to work
    silent = true,
    desc = desc
  })
end

map('n', '<leader>b', build_go_files, "Go: Build or Test")
map('n', '<leader>t', '<Plug>(go-test)', "Go: Test")
map('n', '<leader>r', '<Plug>(go-run)', "Go: Run")
map('n', '<leader>d', '<Plug>(go-doc)', "Go: Doc")
map('n', '<leader>c', '<Plug>(go-coverage-toggle)', "Go: Coverage")
map('n', '<leader>i', '<Plug>(go-info)', "Go: Info")
map('n', '<leader>l', '<Plug>(go-metalinter)', "Go: Metalinter")
map('n', '<leader>v', '<Plug>(go-def-vertical)', "Go: Def Vertical")
map('n', '<leader>s', '<Plug>(go-def-split)', "Go: Def Split")

-------------------------------------------------------------------------------
-- 5. User Commands (A, AV, AS, AT)
-------------------------------------------------------------------------------
-- We use nvim_buf_create_user_command to make these commands available
-- ONLY in the current buffer (Go files).

local function create_cmd(name, action)
  vim.api.nvim_buf_create_user_command(0, name, function(opts)
    local bang = opts.bang and 1 or 0
    vim.fn['go#alternate#Switch'](bang, action)
  end, { bang = true })
end

create_cmd('A',  'edit')
create_cmd('AV', 'vsplit')
create_cmd('AS', 'split')
create_cmd('AT', 'tabe')

vim.api.nvim_buf_create_user_command(0, 'FakeComment', function()
  -- Using vim.cmd because running complex regex subs via Lua API is verbose
  vim.cmd([[%s#^$\n\(type\|func\|interface\) \(\u\w*\)#\r// \2 documentation has been neglected\r\1 \2#]])
end, {})


require('go').setup()
local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
   require('go.format').goimports()
  end,
  group = format_sync_grp,
})

