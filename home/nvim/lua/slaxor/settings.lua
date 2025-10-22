--     vim.o Gets or sets general settings. vim.o.background = 'light'
--     vim.wo Gets or sets window-scoped options. vim.wo.colorcolumn = '80'
--     vim.bo Gets or sets buffer-scoped options. vim.bo.filetype = 'lua'
--     vim.g Gets or sets global variables.
vim.g.mapleader = ","
vim.o.tabstop = 2
vim.o.autoindent = true
vim.o.wrap = false
vim.o.list = true
vim.o.listchars = "trail:░,extends:⮳,precedes:⮰,conceal:?,tab:   " -- ,nbsp:%"
-- if has('unnamedplus')
--   set clipboard^=unnamed
--   set clipboard^=unnamedplus
-- endif
-- if has('persistent_undo')
--   set undofile
--   set undodir=~/tmp/undo/
-- endif
-- filetype plugin indent on
-- let base_dir = "./" . expand("%")
-- let os = substitute(system('uname'), "\n", "", "")
-- let s:maxfontsize = 64
-- let s:minfontsize = 6
-- let s:pattern = '^\(.* \)\([1-9][0-9]*\)$'
-- scriptencoding utf-8
vim.o.autochdir = true
vim.o.autoindent = true
vim.o.backspace = "indent,eol,start"
vim.o.breakindent = true
vim.o.cindent = true
vim.o.clipboard = "unnamedplus"
vim.o.colorcolumn = "+1,+40"
-- vim.o.completeopt = "fuzzy,longest,preview,menuone"
vim.o.completeopt = "fuzzy,preinsert"
vim.o.conceallevel = 0 -- i want to see the text as it is
vim.o.cursorline = true
-- vim.opt.dir = "tmp"
vim.o.display = "uhex"
vim.o.encoding = "utf-8"
-- vim.opt.errorformat += "%f:\ line\ %l\\,\ col\ %c\\,\ %m"
vim.o.expandtab = true
vim.o.fileencodings = "ucs-bom,utf-8,default"
vim.o.formatoptions = "roqnj"   -- :help fo-table
vim.o.grepprg = "rg -S --vimgrep --trim"
-- vim.opt.grepprg=egrep\ -rHn\ --colour=auto\ --exclude=tags\ --exclude=*.tmp\ --exclude=entries\ --exclude=*.log\ --exclude=/tmp/*\ --exclude=*.svn-base\ $*\ .
-- vim.opt.guicursor=n-v-c:block-Cursor/lCursor,ve:ver35-Cursor,o:hor50-Cursor,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor,sm:block-Cursor-blinkwait175-blinkoff150-blinkon175,a:blinkon0
vim.o.hidden = true
vim.o.history=5000
vim.o.hlsearch = true
vim.o.ignorecase = true
vim.o.incsearch = true
vim.o.linebreak = true
vim.o.magic = true
vim.o.mouse = "a"
-- vim.opt.nobackup  -- vim-gitbak does that for me now
vim.o.compatible = false
vim.o.fixeol = false -- don`t be clever, i do my eols myself
vim.o.foldenable = false
vim.o.modeline = false -- this is an ugly invention
vim.o.number = true
vim.o.ruler = true
vim.o.scrolloff=5
vim.o.shiftwidth=2
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.softtabstop=2
vim.o.synmaxcol=400
vim.o.tabstop=2
vim.o.textwidth=72
vim.o.timeout = false
vim.o.ttimeout = true
vim.o.timeoutlen=600
vim.o.viminfo="'20,\"500"
vim.o.virtualedit="all"  -- go beyond $
vim.o.visualbell = true
-- vim.opt.wildignore+=*.o,*.obj,.git/,.bundle/,sass-cache/,tmp/*,*.gif,*.png,*.jpg
vim.o.wildmenu = true
vim.o.window=37
vim.o.writebackup = true
vim.cmd("silent! colorscheme retrobox")
