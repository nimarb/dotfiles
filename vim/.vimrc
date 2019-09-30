" All system-wide defaults are set in $VIMRUNTIME/archlinux.vim (usually just
" /usr/share/vim/vimfiles/archlinux.vim) and sourced by the call to :runtime
" you can find below.  If you wish to change any of those settings, you should
" do it in this file (/etc/vimrc), since archlinux.vim will be overwritten
" everytime an upgrade of the vim packages is performed.  It is recommended to
" make changes after sourcing archlinux.vim since it alters the value of the
" 'compatible' option.

" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages.
runtime! archlinux.vim

" If you prefer the old-style vim functionalty, add 'runtime! vimrc_example.vim'
" Or better yet, read /usr/share/vim/vim73/vimrc_example.vim or the vim manual
" and configure vim to your own liking!

set wrapscan
filetype plugin on
syntax on
"set tabstop=4
set shiftwidth=4
set showcmd
set number
set showmatch
set incsearch
set backspace=2
set history=100
set mouse=a
set hlsearch
set smartcase
set smarttab
set nomodeline
"set backupcopy=yes
"set backupdir=$HOME/.vim/backup
set backupskip=/tmp/*
filetype indent on
imap jj <Esc>
set tabpagemax=20
set background=dark
colorscheme solarized
"set verbose=20
"
autocmd! bufwritepost .vimrc source %
set pastetoggle=<F2>
set clipboard=unnamed
set wildmenu
" Ex mode is dumb
nnoremap Q <Nop>
set lazyredraw

set ruler
set cc=80
set colorcolumn=80

" unlimited undo's by storing them in an undofile, make sure dir exists
set undofile
set undodir=~/.vim/undodir
" delete undofiles older than 90 days
let s:undos = split(globpath(&undodir, '*'), "\n")
call filter(s:undos, 'getftime(v:val) < localtime() - (60 * 60 * 24 *90)')
call map(s:undos, 'delete(v:val)')

call plug#begin('~/.vim/plugged')
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'https://github.com/alok/notational-fzf-vim'
call plug#end()

" Search paths for notational velocity
let g:nv_search_paths = ['~/nextcloud/notes', '~/nextcloud/thoughtson', '~/nextcloud/todo', '~/nextcloud/cdtm' , '~/nextcloud/checklists', '~/progs']

