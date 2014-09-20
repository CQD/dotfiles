set cindent
set cursorline
set encoding=utf8
set expandtab
set fileencoding=utf8
set fileencodings=ucs-bom,utf8,cp950,latin1
set guifont=Inconsolata:h12
set hlsearch
set ignorecase
set incsearch
set laststatus=2
set list
"set listchars=tab:▷⋅,trail:·
set listchars=tab:\ \ ,trail:.
set nobomb
set nocompatible
set number
set ruler
set scrolloff=3
set secure
set smartindent
set tabstop=4
set shiftwidth=4
set showmatch
set smartcase
set t_Co=256
set visualbell
set wildmenu
set backspace=2
set nowrap

syntax on
"
" color schema
if has('gui_running')
    set background=light
else
    set background=dark
endif
let g:solarized_termcolors=256
"colo Tomorrow-Night
colo torte
highlight Search cterm=none ctermbg=blue
"
" keybinding
" nmap <Esc>[Z <C-w>W
" nmap <F2> :NERDTreeToggle<CR>
" nmap <Tab> <C-w>w
"
map <tab><tab> :tabnext<CR>

" other
au BufNewFile,BufRead *.go set filetype=go
au BufNewFile,BufRead *.json setf json
au BufNewFile,BufRead *.mk set noexpandtab
au BufNewFile,BufRead *.psgi setf perl
au BufNewFile,BufRead Makefile set noexpandtab
au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif
"
" call pathogen#infect()
"
" autocmd vimenter * NERDTree | wincmd w
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif


autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType c set omnifunc=ccomplete#Complete
