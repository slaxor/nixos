vim.keymap.set("!", "<c-w>", "<esc>:bd<cr>", {})
vim.keymap.set("!", "<d-enter>", "<insert>", {})
vim.keymap.set("!", "<esc>[5;5~", "<esc>:bp<cr>", {})
vim.keymap.set("!", "<esc>[6;5~", "<esc>:bn<cr>", {})
vim.keymap.set("", "<c-PageDown>", "<esc>:bn<cr>", {})
vim.keymap.set("", "<c-PageUp>", "<esc>:bp<cr>", {})
vim.keymap.set("", "<c-w>", ":bd<cr>", {})
vim.keymap.set("", "<d-enter>", "<insert>", {})
vim.keymap.set("", "<esc><esc>", ":noh<cr>", {})
vim.keymap.set("", "<esc>[5;5~", "<esc>:bp<cr>", {})
vim.keymap.set("", "<esc>[5^", ":bp<cr>", {})
vim.keymap.set("", "<esc>[6;5~", "<esc>:bn<cr>", {})
vim.keymap.set("", "<esc>[6^", ":bn<cr>", {})
vim.keymap.set("", "<leader><left>", ":bp<cr>", {})
vim.keymap.set("", "<leader><right>", ":bn<cr>", {})
vim.keymap.set("", "<leader>e", ':e <C-R>=expand("%:p:h") . "/" <CR>', {})
vim.keymap.set("", "<leader>o", "<esc>:browse oldfiles<cr>", {})
vim.keymap.set("", "<m-c>", "<Plug>NERDCommenterInvert<CR>", {})
-- vim.keymap.set('', '<m-f>', ':Yazi cwd<CR>', {})
vim.keymap.set("", "<m-left>", ":bp<cr>", {})
vim.keymap.set("", "<m-right>", ":bn<cr>", {})
vim.keymap.set("c", "<C-P>", '<C-R>=expand("%:p:h") . "/" <CR>', {})
vim.keymap.set("i", "<c-PageDown>", "<esc>:bn<cr>", {})
vim.keymap.set("i", "<c-PageUp>", "<esc>:bp<cr>", {})
vim.keymap.set("i", "<c-return>", "<plug>(emmet-expand-abbr)", {})
vim.keymap.set("i", "<m-c>", "<ESC><Plug>NERDCommenterInvert<CR>i", {})
-- vim.keymap.set('i', '<m-f>', '<ESC>:Yazi cwd<CR>i', {})
vim.keymap.set("i", "<m-left>", "<esc>:bp<cr>", {})
vim.keymap.set("i", "<m-right>", "<esc>:bn<cr>", {})
vim.keymap.set("n", "<;", "<Plug>Argumentative_MoveLeft", {})
vim.keymap.set("n", "<F2>", ':wa<Bar>exe "mksession! " .. v:this_session<CR>:so ~/.config/nvim/sessions/', {})
vim.keymap.set("n", "<d-Down>", "]e", {})
vim.keymap.set("n", "<d-Up>", "[e", {})
vim.keymap.set("n", "<leader>c", "/<<<<<<< \\_.\\{-}=======\\_.\\{-}>>>>>>>.*/<CR>", {})
vim.keymap.set("n", "<leader>sd", ":w !diff -y --ignore-all-space --suppress-common-lines % -<CR>", {})
vim.keymap.set("n", "<silent>", "<Leader>xo :wincmd j<CR>", {})
vim.keymap.set("n", ">;", "<Plug>Argumentative_MoveRight", {})
vim.keymap.set("n", "[;", "<Plug>Argumentative_Prev", {})
vim.keymap.set("n", "];", "<Plug>Argumentative_Next", {})
vim.keymap.set("o", "a;", "<Plug>Argumentative_OpPendingOuterTextObject", {})
vim.keymap.set("o", "i;", "<Plug>Argumentative_OpPendingInnerTextObject", {})
vim.keymap.set("v", "<d-Down>", "]egv", {})
vim.keymap.set("v", "<d-Up>", "[egv", {})
vim.keymap.set("v", "<m-Down>", ":m'>+1<CR>gv", { silent = true })
vim.keymap.set("v", "<m-Up>", ":m'<-2<CR>gv", { silent = true })
vim.keymap.set("v", "<m-c>", "<Plug>NERDCommenterInvert<CR>", {})
vim.keymap.set("v", "<s-c-c>", '<esc>"+y<cr>', {})
vim.keymap.set("v", "<s-c-v>", '<esc>"+gp<cr>', {})
vim.keymap.set("v", "<s-c-x>", '<esc>"+x<cr>', {})
vim.keymap.set("x", "[;", "<Plug>Argumentative_XPrev", {})
vim.keymap.set("x", "];", "<Plug>Argumentative_XNext", {})
vim.keymap.set("x", "a;", "<Plug>Argumentative_OuterTextObject", {})
vim.keymap.set("x", "i;", "<Plug>Argumentative_InnerTextObject", {})
vim.keymap.set("i", "<leader>p", InsertPassword, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>p", InsertPassword, { noremap = true, silent = true })

-- vim.keymap.set({'n', 'v'}, '<leader>pg', function()
-- local password = vim.fn.system('pwgen -scny 13 1'):gsub('\n$', '')
-- local mode = vim.fn.mode()
-- if mode == 'v' or mode == 'V' then
-- vim.api.nvim_put({ password }, 'c', true, true)
-- else
-- vim.api.nvim_put({ password }, 'c', false, true)
-- end
-- end, { desc = 'Insert/replace with password' })

vim.cmd("abbr 8< -----------8<-----------8<-----------8<-----------")
vim.cmd("abbr >8 ----------->8----------->8----------->8-----------")
vim.cmd("abbr \\...  …")
vim.cmd("abbr retrun return")
vim.cmd("abbr retunr return")

vim.keymap.set("n", "<C-=>", function()
	local word = vim.fn.expand("<cword>")
	local rval = ""
	if word == "true" then
		rval = "m`ciwfalse<Esc>``"
	elseif word == "false" then
		rval = "m`ciwtrue<Esc>``"
	elseif word == "True" then
		rval = "m`ciwFalse<Esc>``"
	elseif word == "False" then
		rval = "m`ciwTrue<Esc>``"
	end
	return rval
end, { expr = true, desc = "Toggle boolean" })
