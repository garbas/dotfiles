{ pkgs, base16, base16Theme }:
{
  customRC = ''

if has("nvim")
  tnoremap <Esc> <C-\><C-n>
  tnoremap <C-h> <C-\><C-n><C-w>h
  tnoremap <C-j> <C-\><C-n><C-w>j
  tnoremap <C-k> <C-\><C-n><C-w>k
  tnoremap <C-l> <C-\><C-n><C-w>l
  autocmd BufWinEnter,WinEnter term://* startinsert
  autocmd BufLeave term://* stopinsert
endif

let mapleader = ","
let maplocalleader = "\\"

" Addons ------------------------------------------------------------------ {{{

let g:gist_detect_filetype = 1
let g:gist_open_browser_after_post = 1
let g:gist_browser_command = "${pkgs.firefox} %URL%"

let g:ctrlp_dont_split = "NERD_tree_2"
let g:ctrlp_extensions = ["undo", "bookmarkdir", "funky"]
let g:ctrlp_jump_to_buffer = 0
let g:ctrlp_map = "<leader><leader>"
let g:ctrlp_match_window_reversed = 1
let g:ctrlp_max_height = 20
let g:ctrlp_open_new_file = "v"
let g:ctrlp_open_multiple_files = '2vjr'
let g:ctrlp_split_window = 0
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_follow_symlinks = 1
let g:ctrlp_user_command = {
  \ 'types': {
    \ 1: ['.git/', 'cd %s && git ls-files'],
    \ 2: ['.hg/', 'hg --cwd %s locate -I .'],
    \ },
  \ 'fallback': 'find %s -type f'
  \ }

   nnoremap <LEADER>. :CtrlPBuffer<cr>
nnoremap <LEADER>b :CtrlPBookmarkDir<cr>

let g:airline_theme = "base16"
let g:airline_powerline_fonts = 0

let g:syntastic_check_on_open=1
let g:syntastic_auto_jump=0
let g:syntastic_stl_format = '[%E{%e Errors}%B{, }%W{%w Warnings}]'

let g:UltiSnipsExpandTrigger="<leader><tab>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"

" Default highlighting (see help :highlight and help :highlight-link)
highlight multiple_cursors_cursor term=reverse cterm=reverse gui=reverse
highlight link multiple_cursors_visual Visual

" }}}
" Basic options ----------------------------------------------------------- {{{
" General options {{{
set nocompatible
set encoding=utf-8
set modelines=0
set autoindent
set showmode
set showcmd
set hidden
set visualbell
set cursorline
set ttyfast
set ruler
set backspace=indent,eol,start
set number
set norelativenumber
set laststatus=2
set history=1000
set undofile
set undoreload=10000
set cpoptions+=J
set listchars=tab:▸\ ,eol:¬,extends:❯,precedes:❮
set lazyredraw
set matchtime=3
set showbreak=↪
set splitbelow
set splitright
set fillchars=diff:⣿
set ttimeout
set notimeout
set nottimeout
set autowrite
set shiftround
set autoread
set title
set linebreak
"set dictionary=/usr/share/dict/words
set completeopt=longest,menuone,preview  " Better Completion
set pastetoggle=<F2>  " Toggle paste

" Save when losing focus
"au FocusLost * :wa

" Resize splits when the window is resized
au VimResized * exe "normal! \<c-w>="

" set all window splits equal
set equalalways

" }}}
" Wildmenu completion {{{

set wildmenu
set wildmode=list:longest

set wildignore+=.hg,.git,.svn                    " Version control
set wildignore+=*.aux,*.out,*.toc                " LaTeX intermediate files
set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg   " binary images
set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest " compiled object files
set wildignore+=*.spl                            " compiled spelling word lists
set wildignore+=*.sw?                            " Vim swap files
set wildignore+=*.DS_Store                       " OSX bullshit

set wildignore+=*.luac                           " Lua byte code

set wildignore+=migrations                       " Django migrations
set wildignore+=*.pyc                            " Python byte code

set wildignore+=*.orig                           " Merge resolution files

" Clojure/Leiningen
set wildignore+=classes
set wildignore+=lib

" }}}
" Line Return {{{

" Make sure Vim returns to the same line when you reopen a file.
" Thanks, Amit
augroup line_return
    au!
    au BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \     execute 'normal! g`"zvzz' |
        \ endif
augroup END

" }}}
" Tabs, spaces, wrapping {{{

set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set wrap
set textwidth=79
set formatoptions=qrn1
set colorcolumn=+1

" }}}
" Backups {{{

set backupdir=~/.vim/backup//     " backups
set backupskip=/tmp/*,/private/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*¬
set undodir=~/.vim/tmp/undo//     " undo files
set directory=~/.vim/tmp/swap//    " swap files
set backup                        " enable backups
set noswapfile                    " It's 2012, Vim.

" }}}
" Color scheme {{{

let base16colorspace=256
let g:base16_shell_path="${base16}/shell"

syntax on
filetype on
filetype plugin on
filetype plugin indent on

set background=dark

" Highlight VCS conflict markers
match ErrorMsg "^\(<\|=\|>\)\{7\}\([^=].\+\)\?$"

" Highlight lines that are longer then 80
match ErrorMsg '\%>80v.+'

" }}}
" }}}
" Searching and movement -------------------------------------------------- {{{
" General {{{

" Use sane regexes.
nnoremap / /\v
vnoremap / /\v

set ignorecase
set smartcase
set incsearch
set showmatch
set hlsearch
set gdefault

set scrolloff=3
set sidescroll=1
set sidescrolloff=10

set virtualedit+=block

noremap <LEADER><space> :noh<cr>:call clearmatches()<cr>

runtime macros/matchit.vim
map <tab> %

" Made D behave
nnoremap D d$

" Keep search matches in the middle of the window and pulse the line when moving
" to them.
nnoremap n nzzzv
nnoremap N Nzzzv

" Don't move on *
nnoremap * *<c-o>

" Same when jumping around
nnoremap g; g;zz
nnoremap g, g,zz

" Window resizing
nnoremap <c-left> 5<c-w>>
nnoremap <c-right> 5<c-w><

" Easier to type, and I never use the default behavior.
noremap H ^
noremap L g_

" Heresy
inoremap <c-a> <esc>I
inoremap <c-e> <esc>A

" Open a Quickfix window for the last search.
nnoremap <silent> <LEADER>/ :execute "vimgrep /".@/."/g %"<CR>:copen<CR>

" Ack for the last search.
nnoremap <silent> <LEADER>? :execute "Ack! '" . substitute(substitute(substitute(@/, "\\\\<", "\\\\b", ""), "\\\\>", "\\\\b", ""), "\\\\v", "", "") . "'"<CR>

" Fix linewise visual selection of various text objects
nnoremap VV V
nnoremap Vit vitVkoj
nnoremap Vat vatV
nnoremap Vab vabV
nnoremap VaB vaBV

" }}}
" Error navigation {{{
"
"             Location List     QuickFix Window
"            (e.g. Syntastic)     (e.g. Ack)
"            ----------------------------------
" Next      |     M-j               M-Down     |
" Previous  |     M-k                M-Up      |
"            ----------------------------------
"
nnoremap ∆ :lnext<cr>zvzz
nnoremap ˚ :lprevious<cr>zvzz
inoremap ∆ <esc>:lnext<cr>zvzz
inoremap ˚ <esc>:lprevious<cr>zvzz
nnoremap <m-Down> :cnext<cr>zvzz
nnoremap <m-Up> :cprevious<cr>zvzz

" }}}
" Directional Keys {{{

" It's 2011.
noremap j gj
noremap k gk

" Easy buffer navigation
noremap <C-h>  <C-w>h
noremap <C-j>  <C-w>j
noremap <C-k>  <C-w>k
noremap <C-l>  <C-w>l
noremap <LEADER>v <C-w>v

" }}}
" Highlight word {{{

nnoremap <silent> <LEADER>hh :execute 'match InterestingWord1 /\<<c-r><c-w>\>/'<cr>
nnoremap <silent> <LEADER>h1 :execute 'match InterestingWord1 /\<<c-r><c-w>\>/'<cr>
nnoremap <silent> <LEADER>h2 :execute '2match InterestingWord2 /\<<c-r><c-w>\>/'<cr>
nnoremap <silent> <LEADER>h3 :execute '3match InterestingWord3 /\<<c-r><c-w>\>/'<cr>

" }}}
" Visual Mode */# from Scrooloose {{{

function! s:VSetSearch()
  let temp = @@
  norm! gvy
  let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
  let @@ = temp
endfunction

vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR><c-o>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR><c-o>

" }}}
" }}}
" Folding ----------------------------------------------------------------- {{{

set foldlevelstart=0

" Space to toggle folds.
nnoremap <Space> za
vnoremap <Space> za

" Make zz recursively open whatever top level fold we're in, no matter where the
" cursor happens to be.
nnoremap zz zCzO

" Use ,z to "focus" the current fold.
nnoremap <LEADER>z zMzvzz

function! MyFoldText() " {{{
    let line = getline(v:foldstart)

    let nucolwidth = &fdc + &number * &numberwidth
    let windowwidth = winwidth(0) - nucolwidth - 3
    let foldedlinecount = v:foldend - v:foldstart

    " expand tabs into spaces
    let onetab = strpart('          ', 0, &tabstop)
    let line = substitute(line, '\t', onetab, 'g')

    let line = strpart(line, 0, windowwidth - 2 -len(foldedlinecount))
    let fillcharcount = windowwidth - len(line) - len(foldedlinecount)
    return line . '…' . repeat(" ",fillcharcount) . foldedlinecount . '…' . ' '
endfunction " }}}
set foldtext=MyFoldText()

" }}}
" Destroy infuriating keys ------------------------------------------------ {{{

" Fuck you, help key.
noremap  <F1> :set invfullscreen<CR>
inoremap <F1> <ESC>:set invfullscreen<CR>a

" Fuck you too, manual key.
nnoremap K <nop>

" Stop it, hash key.
inoremap # X<BS>#

" Use L, dammit.
nnoremap Ajk <nop>
nnoremap A<esc> <nop>

" }}}
" Various filetype-specific stuff ----------------------------------------- {{{
" C {{{

augroup ft_c
    au!
    au FileType c setlocal foldmethod=syntax
augroup END

" }}}
" CSS and LessCSS {{{

augroup ft_css
    au!

    au BufNewFile,BufRead *.less setlocal filetype=less

    au Filetype less,css setlocal foldmethod=marker
    au Filetype less,css setlocal ts=2 sts=2 sw=2
    au Filetype less,css setlocal foldmarker={,}
    au Filetype less,css setlocal omnifunc=csscomplete#CompleteCSS
    au Filetype less,css setlocal iskeyword+=-

    " Use <LEADER>S to sort properties. Turns this:
    "
    " p {
    " width: 200px;
    " height: 100px;
    " background: red;
    "
    " ...
    " }
    "
    " into this:
    "
    " p {
    " background: red;
    " height: 100px;
    " width: 200px;
    "
    " ...
    " }
    au BufNewFile,BufRead *.less,*.css nnoremap <buffer> <localleader>S ?{<CR>jV/\v^\s*\}?$<CR>k:sort<CR>:noh<CR>

    " Make {<cr> insert a pair of brackets in such a way that the cursor is correctly
    " positioned inside of them AND the following code doesn't get unfolded.
    au BufNewFile,BufRead *.less,*.css inoremap <buffer> {<cr> {}<left><cr><space><space><space><space>.<cr><esc>kA<bs>
augroup END

" }}}
" HTML {{{

augroup ft_html
    au!

    au BufNewFile,BufRead *.html *.pt *.zcml setlocal filetype=html
    au FileType html setlocal foldmethod=manual
    au Filetype html setlocal ts=2 sts=2 sw=2

    " Use <localleader>f to fold the current tag.
    au FileType html nnoremap <buffer> <localleader>f Vatzf


    " Use Shift-Return to turn this:
    " <tag>|</tag>
    "
    " into this:
    " <tag>
    " |
    " </tag>
    au FileType html nnoremap <buffer> <s-cr> vit<esc>a<cr><esc>vito<esc>i<cr><esc>

    " Smarter pasting
    "au FileType html nnoremap <buffer> p :<C-U>YRPaste 'p'<CR>v`]=`]
    "au FileType html nnoremap <buffer> P :<C-U>YRPaste 'P'<CR>v`]=`]
    "au FileType html nnoremap <buffer> π :<C-U>YRPaste 'p'<CR>
    "au FileType html nnoremap <buffer> ∏ :<C-U>YRPaste 'P'<CR>

augroup END

" }}}
" Javascript {{{

augroup ft_javascript
    au!

    au FileType javascript setlocal foldmethod=marker
    au FileType javascript setlocal foldmarker={,}
    au Filetype javascript setlocal ts=2 sts=2 sw=2

    au BufRead,BufNewFile jquery.*.js set ft=javascript syntax=jquery

augroup END

" }}}
" Lisp {{{

augroup ft_lisp
    au!
    au FileType lisp call TurnOnLispFolding()
augroup END

" }}}
" Markdown {{{

augroup ft_markdown
    au!

    au BufNewFile,BufRead *.m*down setlocal filetype=markdown

    " Use <localleader>1/2/3 to add headings.
    au Filetype markdown nnoremap <buffer> <localleader>1 yypVr=
    au Filetype markdown nnoremap <buffer> <localleader>2 yypVr-
    au Filetype markdown nnoremap <buffer> <localleader>3 I### <ESC>
augroup END

" }}}
" Nginx {{{

augroup ft_nginx
    au!

    au BufNewFile,BufRead /etc/nginx/conf/* set ft=nginx
    au BufNewFile,BufRead /etc/nginx/sites-available/* set ft=nginx
    au BufNewFile,BufRead /usr/local/etc/nginx/sites-avaialble/* set ft=nginx
    au BufNewFile,BufRead vhost.ngingx set ft=nginx

    au FileType nginx setlocal foldmethod=marker foldmarker={,}
augroup END

" }}}
" Python {{{

augroup ft_python
    au!

    au FileType python setlocal omnifunc=pythoncomplete#Complete
    au FileType python setlocal define=^\s*\\(def\\\\|class\\)
augroup END

" }}}
" ReStructuredText {{{

augroup ft_rest
    au!

    au FileType rst nnoremap <buffer> <localleader>1 yypVr=
    au FileType rst nnoremap <buffer> <localleader>2 yypVr-
    au FileType rst nnoremap <buffer> <localleader>3 yypVr~
    au FileType rst nnoremap <buffer> <localleader>4 yypVr`
augroup END

" }}}
" Vim {{{

augroup ft_vim
    au!

    au FileType vim setlocal foldmethod=marker
    au FileType help setlocal textwidth=78
    au BufWinEnter *.txt if &ft == 'help' | wincmd L | endif
augroup END

" }}}
" }}}
" Convenience mappings ----------------------------------------------------- {{{

nmap <LEADER>L :set list!<CR>
map <SILENT> <LEADER>S :set spell!<CR>
map <SILENT> <LEADER>H :set hlsearch!<CR>¬
map <SILENT> <LEADER>N :set number!<CR>

" Clean whitespace
map <leader>W :%s/\s\+$//<cr>:let @/=""<CR>

" Change case
nnoremap <C-u> gUiw
inoremap <C-u> <esc>gUiwea

" Emacs bindings in command line mode
cnoremap <c-a> <home>
cnoremap <c-e> <end>

" Formatting, TextMate-style
nnoremap <leader>w gqip

" Align text
nnoremap <leader>Al :left<cr>
nnoremap <leader>Ac :center<cr>
nnoremap <leader>Ar :right<cr>

" Less chording
nnoremap ; :

" Faster Esc
inoremap jj <esc>

" Marks and Quotes
noremap ' `
noremap æ '
noremap ` <C-^>

" Calculator
inoremap <C-B> <C-O>yiW<End>=<C-R>=<C-R>0<CR>

" Show syntax highlighting groups for word under cursor
nmap <C-S-P> :call <SID>SynStack()<CR>
function! <SID>SynStack()
    if !exists("*synstack")
        return
    endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

" }}}

${builtins.readFile "${base16}/vim/base16-${base16Theme}.vim"}
${builtins.readFile "${base16}/vim-airline/base16-${base16Theme}.vim"}

  '';
  vam.pluginDictionaries = [
    { names = [
        "css_color_5056"
        "vim-webdevicons"
        "Gist"
        "Syntastic"
        "UltiSnips"
        "calendar-vim"
        "commentary"
        "ctrlp"
        "ctrlp-py-matcher"
        "ctrlp-z"
        "fugitive"
        "goyo"
        "sensible"
        "vim-addon-nix"
        "vim-airline"
        "vim-multiple-cursors"
        "vim-signature"
        "vim-signify"
        "vim-snippets"
        "youcompleteme"
      ];
    }
  ];
}
