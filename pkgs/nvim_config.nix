{ pkgs
, theme ? null
}:
{
  customRC = ''
    let mapleader = "\<Space>"
    let maplocalleader = ","

    " general
    set number
    set norelativenumber

    " history / backup / undo
    set history=1000
    set undofile
    set undoreload=10000
    set undodir=~/.vim/tmp/undo/
    set backup
    set backupdir=~/.vim/backup/
    set backupskip=/tmp/*,/private/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*
    set noswapfile
    set directory=~/.vim/tmp/swap/

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

    if readfile('/tmp/theme-brightness')[0] == 'dark'
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


    " vim-startify

    let g:startify_enable_special         = 0
    let g:startify_files_number           = 8
    let g:startify_relative_path          = 1
    let g:startify_change_to_dir          = 1
    let g:startify_update_oldfiles        = 1
    let g:startify_session_autoload       = 1
    let g:startify_session_persistence    = 1
    let g:startify_session_delete_buffers = 1

    let g:startify_list_order = [
      \ ['   Bookmarks:'],
      \ 'bookmarks',
      \ ['   Sessions:'],
      \ 'sessions',
      \ ['   Recent in this dir:'],
      \ 'dir',
      \ ['   Recent:'],
      \ 'files',
      \ ]

    let g:startify_bookmarks = [
      \ { 'c': '~/dev/dotfiles/pkgs/nvim_config.nix' },
      \ { 'n': '~/dev/nixos/nixpkgs' },
      \ '~/dev/mozilla/relengapi/src/relengapi_tools/',
      \ ]

    let g:startify_custom_footer =
      \ ["", "   Vim is charityware. Please read ':help uganda'.", ""]

    hi StartifyBracket ctermfg=240
    hi StartifyFile    ctermfg=147
    hi StartifyFooter  ctermfg=240
    hi StartifyHeader  ctermfg=114
    hi StartifyNumber  ctermfg=215
    hi StartifyPath    ctermfg=245
    hi StartifySlash   ctermfg=240
    hi StartifySpecial ctermfg=240

    " deoplete.
    let g:deoplete#enable_at_startup = 1
    let g:deoplete#enable_smart_case = 1
    let g:deoplete#sources = {}
    let g:deoplete#sources._ = ['buffer', 'file', 'omni', 'ultisnips']
    "let g:deoplete#sources.python = ['jedi']
    "let g:deoplete#sources.rust = ['racer']
    "let g:deoplete#sources.javascript = ['termjs']

    set completeopt=longest,menuone,preview  " Better Completion

    " Let <Tab> also do completion
    inoremap <silent><expr> <Tab>
    \ pumvisible() ? "\<C-n>" :
    \ deoplete#mappings#manual_complete()

    " Close the documentation window when completion is done
    autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif


    "neomake
    autocmd! BufWritePost * Neomake


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

  '' + pkgs.lib.optionalString (theme != null) ''
    if !has('gui_running')
      execute "silent !/bin/sh ${theme}/shell.".&background
    endif
    let base16colorspace = "256"
    ${builtins.readFile "${theme}/vim.dark"}
  '';

  vam.pluginDictionaries = [
    { names = [
            "UltiSnips"
    #        "commentary"
    #        "deoplete-nvim"
    #        "floobits-neovim"
    #        "fugitive"
            "fzf-vim"
            "fzfWrapper"
            "goyo"
            "neoformat"
            "neomake"
    #        "rust-vim"
            "sensible"
            "vim-leader-guide"  # needs to be loaded before spacevim
            "spacevim"
            "surround"
    #        "vim-airline"
    #        "vim-airline-themes"
    #        "vim-css-color"
    #        "vim-eunuch"
            "vim-expand-region"
            "vim-gista"
    #        "vim-multiple-cursors"
            "vim-nix"
    #        "vim-orgmode"
    #        "vim-peekaboo"
            "vim-polyglot"
    #        "vim-racer"
            "vim-signature"
            "vim-signify"
            "vim-snippets"
            "vim-startify"
            "vim-devicons"
    #        "vimpreviewpandoc"
            "vim-auto-save"

        #"deoplete-jedi"

        # TODO:
        # tab doesn work
        # https://github.com/zchee/deoplete-jedi
        # https://github.com/carlitux/deoplete-ternjs
        # ligatures
        #   https://github.com/neovim/neovim/issues/1408
        #   https://github.com/i-tu/Hasklig
        #   https://github.com/romeovs/creep/blob/master/creep.vim
        # https://github.com/jaxbot/github-issues.vim
        # https://github.com/codegram/vim-codereview
        # vim + javascript
        #   http://www.panozzaj.com/blog/2015/08/28/must-have-vim-javascript-setup/
        #   https://davidosomething.com/blog/vim-for-javascript/
        #   http://oli.me.uk/2013/06/29/equipping-vim-for-javascript/
        #   https://www.reddit.com/r/vim/comments/3ixtpg/vimjsindent/
        # nice example of configuration of pluggins
        #   https://github.com/luan/vimfiles
      ];
    }
  ];
}
