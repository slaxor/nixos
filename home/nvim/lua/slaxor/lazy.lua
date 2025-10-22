local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { 'arouene/vim-ansible-vault' },
  { 'SirVer/ultisnips' },
  { 'WhoIsSethDaniel/toggle-lsp-diagnostics.nvim' },
  { 'cespare/vim-toml' },
  {
    'chomosuke/typst-preview.nvim',
    ft = 'typst',
    build = ':TypstPreviewUpdate',
  },
  { 'digitaltoad/vim-pug' },
  { 'fholgado/minibufexpl.vim' },
  { 'folke/snacks.nvim' },
  { 'fredrikaverpil/godoc.nvim' },
  { 'honza/vim-snippets' },
  { 'iamcco/markdown-preview.nvim', },
  { 'junegunn/fzf', dir = '~/.fzf', build = './install --all' },
  { 'junegunn/vim-easy-align' },
  { 'kaarmu/typst.vim', ft = 'typst' },
  { 'lewis6991/spaceless.nvim' },
  { 'mattn/emmet-vim', ft = 'html' },
  { 'mattn/vim-sonictemplate' },
  { 'mikavilpas/yazi.nvim' },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'quangnguyen30192/cmp-nvim-ultisnips',
    },
  },
  { 'neovim/nvim-lspconfig' },
  { 'nsf/gocode', rtp = 'vim' }, -- 'rtp' bleibt gleich
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
    },
  },
  { 'abayomi185/nvim-dap-probe-rs' },
  { 'nvim-lua/plenary.nvim' },
  { 'nvim-neotest/nvim-nio' },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-media-files.nvim',
    },
  },
  {
    'renerocksai/telekasten.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telekasten/calendar-vim',
    },
  },
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },

  { 'plasticboy/vim-markdown', ft = 'markdown' },
  { 'posva/vim-vue' },
  { 'preservim/nerdtree', cmd = 'NERDTreeToggle' },
  { 'ray-x/go.nvim' },
  { 'ray-x/guihua.lua' },
  { 'rust-lang/rust.vim', ft = 'rust' },
  { 'ryanoasis/vim-devicons' },
  { 'sbdchd/neoformat' },
  { 'scrooloose/nerdcommenter' },
  { 'slaxor/vim-gitbak' },
  { 'slint-ui/vim-slint' },
  { 'terryma/vim-multiple-cursors' },
  { 'tpope/vim-abolish' },
  { 'vim-scripts/file-line' },
  { 'vim-scripts/sudo.vim' },
  { 'vim-scripts/visual-increment' },
  { "folke/trouble.nvim",
    modes = {
      preview_float = {
        mode = "diagnostics",
        preview = {
          type = "float",
          relative = "editor",
          border = "rounded",
          title = "Preview",
          title_pos = "center",
          position = { 0, -2 },
          size = { width = 0.3, height = 0.3 },
          zindex = 200,
        },
      },
    },
    opts = {},
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  }
  -- { 'fatih/vim-go', tag = '*' },
})
