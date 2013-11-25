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
"set backupcopy=yes
"set backupdir=$HOME/.vim/backup
set backupskip=/tmp/*
filetype indent on
imap jj <Esc>
set tabpagemax=20
set background=dark
colorscheme solarized
