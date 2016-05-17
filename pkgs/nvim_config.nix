{ pkgs, base16Theme }:
{
  customRC = ''

let mapleader = "\<Space>"
let maplocalleader = ","

" general
set number
set norelativenumber

" Save when losing focus
au FocusLost * :wa

" Resize splits when the window is resized
au VimResized * exe "normal! \<c-w>="

" set all window splits equal
set equalalways

" Make sure Vim returns to the same line when you reopen a file.
" Thanks, Amit
augroup line_return
    au!
    au BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \     execute 'normal! g`"zvzz' |
        \ endif
augroup END

" Keep search matches in the middle of the window and pulse the line when moving
" to them.
nnoremap n nzzzv
nnoremap N Nzzzv

" Clean whitespace
map <leader>W :%s/\s\+$//<cr>:let @/=""<CR>

" Formatting, TextMate-style
nnoremap <leader>E gqip

" Less chording
nnoremap ; :

" Faster Esc
inoremap jj <esc>

" Easy buffer navigation
noremap <C-h>  <C-w>h
noremap <C-j>  <C-w>j
noremap <C-k>  <C-w>k
noremap <C-l>  <C-w>l
noremap <leader>v <c-w>v

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

" Tabs, spaces, wrapping
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set wrap
set textwidth=79
set formatoptions=qrn1
set colorcolumn=+1

" Backup
set backupdir=~/.vim/backup//     " backups
set backupskip=/tmp/*,/private/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*¬
set undodir=~/.vim/tmp/undo//     " undo files
set directory=~/.vim/tmp/swap//    " swap files
set backup                        " enable backups
set noswapfile                    " It's 2012, Vim.

" theme
let base16colorspace=256
let g:base16_shell_path="${pkgs.base16}/shell"

if readfile('/tmp/theme-config')[0] == 'dark'
  set background=dark
else
  set background=light
endif

syntax on
filetype on
filetype plugin on
filetype plugin indent on

" Highlight VCS conflict markers
match ErrorMsg "^\(<\|=\|>\)\{7\}\([^=].\+\)\?$"

" Highlight lines that are longer then 80
match ErrorMsg '\%>80v.+'



" Type <Space>w to save file (a lot faster than :w<Enter>):
nnoremap <Leader>w :w<CR>

" Copy & paste to system clipboard with <Space>p and <Space>y
vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P

" Enter visual line mode with <Space><Space>
nmap <Leader><Leader> V

" Use region expanding
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)

" Automatically jump to end of text you pasted:
vnoremap <silent> y y`]
vnoremap <silent> p p`]
nnoremap <silent> p p`]

" Quickly select text you just pasted
noremap gV `[v`]

" Prevent replacing paste buffer on paste:
" vp doesn't replace paste buffer
function! RestoreRegister()
  let @" = s:restore_reg
  return '''
endfunction
function! s:Repl()
  let s:restore_reg = @"
  return "p@=RestoreRegister()\<cr>"
endfunction
vmap <silent> <expr> p <sid>Repl()


" ultisnips
let g:UltiSnipsExpandTrigger="<leader><tab>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"


" deoplete.
let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_smart_case = 1


" vim-airline
let g:airline_theme = "base16"
let g:airline_powerline_fonts = 1


" multiple cursors
" Default highlighting (see help :highlight and help :highlight-link)
highlight multiple_cursors_cursor term=reverse cterm=reverse gui=reverse
highlight link multiple_cursors_visual Visual


" neovim
if has("nvim")
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  tnoremap <Esc> <C-\><C-n>
  tnoremap <C-h> <C-\><C-n><C-w>h
  tnoremap <C-j> <C-\><C-n><C-w>j
  tnoremap <C-k> <C-\><C-n><C-w>k
  tnoremap <C-l> <C-\><C-n><C-w>l
  autocmd BufWinEnter,WinEnter term://* startinsert
  autocmd BufLeave term://* stopinsert
endif


${builtins.readFile "${pkgs.base16}/vim/base16-${base16Theme}.vim"}
${builtins.readFile "${pkgs.base16}/vim-airline/base16-${base16Theme}.vim"}

  '';
  vam.pluginDictionaries = [
    { names = [
        "UltiSnips"
        "commentary"
        "deoplete-nvim"
        "fugitive"
        "fzf"
        "fzf-vim"
        "goyo"
        "neomake"
        "rust-vim"
        "sensible"
        "spacevim"
        "surround"
        "unite-vim"
        "vim-addon-nix"
        "vim-airline"
        "vim-airline-themes"
        "vim-css-color"
        "vim-eunuch"
        "vim-expand-region"
        "vim-gista"
        "vim-leader-guide"
        "vim-multiple-cursors"
        "vim-orgmode"
        "vim-peekaboo"
        "vim-racer"
        "vim-signature"
        "vim-signify"
        "vim-snippets"
        "vim-startify"
        "vim-webdevicons"
        "vimpreviewpandoc"

        # TODO:
        # https://github.com/zchee/deoplete-jedi
        # https://github.com/carlitux/deoplete-ternjs
      ];
    }
  ];
}
