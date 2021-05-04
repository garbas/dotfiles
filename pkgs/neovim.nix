{ default
, theme

, neovim

, vimPlugins
, nodejs
, lib
}:

let
  preConfig = ''
    set shell=/bin/sh
  '';

  postConfig = ''
  '';

  pluginsWithConfig = [

    # SENSIBLE DEFAULTS
    { plugins = with vimPlugins; [
        # One step above 'nocompatible' mode
        # https://github.com/tpope/vim-sensible
        vim-sensible

        # One step above sensible.vim more defaults to agree on
        # https://github.com/jeffkreeftmeijer/neovim-sensible
        neovim-sensible
      ];
      config = "";
    }

    # THEME / COLORS / ICONS
    { plugins = with vimPlugins; [
        vim-airline
        vim-airline-themes
        vim-devicons
      ];
      config = ''
        set termguicolors
        set background=dark
        let g:one_allow_italics = 1
        let g:airline_theme='${default.theme}'

        ${builtins.readFile theme.vim}
      '';
    }

    # CORE
    { plugins = with vimPlugins; [
        # The fancy start screen for Vim.
        # https://github.com/mhinz/vim-startify
        vim-startify

        vim-which-key
      ];
      config = ''
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
          \ { 'c': '~/dev/dotfiles/nixos/vim_config.nix' },
          \ { 'n': '~/dev/nixos/nixpkgs-channels' },
          \ '~/dev/mozilla/services',
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

        let g:mapleader = "\<Space>"
        let g:maplocalleader = ','
        nnoremap <silent> <leader>      :<c-u>WhichKey '<Space>'<CR>
        nnoremap <silent> <localleader> :<c-u>WhichKey  ','<CR>
        set timeoutlen=500

        let g:which_key_use_floating_win = 1
        "TODO
        "let g:which_key_floating_opts = { 'row': '-1' }
        let g:which_key_map =  {}
        let g:which_key_localmap =  {}

        autocmd VimEnter * call which_key#register('<Space>', "g:which_key_map")
        autocmd VimEnter * call which_key#register(',', "g:which_key_localmap")
        nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>
        vnoremap <silent> <leader> :<c-u>WhichKeyVisual '<Space>'<CR>

        let g:which_key_map.b = {
              \ 'name' : '+buffer' ,
              \ 'b' : ['Buffers'   , 'fzf-buffer']      ,
              \ 'h' : ['Startify'  , 'home-buffer']     ,
              \ '1' : ['b1'        , 'buffer 1']        ,
              \ '2' : ['b2'        , 'buffer 2']        ,
              \ '3' : ['b3'        , 'buffer 3']        ,
              \ '4' : ['b4'        , 'buffer 4']        ,
              \ '5' : ['b5'        , 'buffer 5']        ,
              \ '6' : ['b6'        , 'buffer 6']        ,
              \ '7' : ['b7'        , 'buffer 7']        ,
              \ '8' : ['b8'        , 'buffer 8']        ,
              \ '9' : ['b9'        , 'buffer 9']        ,
              \ '0' : ['b0'        , 'buffer 0']        ,
              \ 'd' : ['bd'        , 'delete-buffer']   ,
              \ 'f' : ['bfirst'    , 'first-buffer']    ,
              \ 'l' : ['blast'     , 'last-buffer']     ,
              \ 'n' : ['bnext'     , 'next-buffer']     ,
              \ 'p' : ['bprevious' , 'previous-buffer'] ,
              \ }

        let g:which_key_map.w = {
          \ 'name' : '+windows' ,
          \ 'w' : ['Windows'    , 'fzf-window']            ,
          \ 'W' : ['<C-W>w'     , 'other-window']          ,
          \ 'd' : ['<C-W>c'     , 'delete-window']         ,
          \ '-' : ['<C-W>s'     , 'split-window-below']    ,
          \ '|' : ['<C-W>v'     , 'split-window-right']    ,
          \ '2' : ['<C-W>v'     , 'layout-double-columns'] ,
          \ 'h' : ['<C-W>h'     , 'window-left']           ,
          \ 'j' : ['<C-W>j'     , 'window-below']          ,
          \ 'l' : ['<C-W>l'     , 'window-right']          ,
          \ 'k' : ['<C-W>k'     , 'window-up']             ,
          \ 'H' : ['<C-W>5<'    , 'expand-window-left']    ,
          \ 'J' : ['resize +5'  , 'expand-window-below']   ,
          \ 'L' : ['<C-W>5>'    , 'expand-window-right']   ,
          \ 'K' : ['resize -5'  , 'expand-window-up']      ,
          \ '=' : ['<C-W>='     , 'balance-window']        ,
          \ 's' : ['<C-W>s'     , 'split-window-below']    ,
          \ 'v' : ['<C-W>v'     , 'split-window-below']    ,
          \ }

        let g:which_key_map.f = {
          \ 'name' : '+fzf' ,
          \ 'f' : ['Files'      , 'fzf-files']             ,
          \ 'g' : ['GFiles'     , 'fzf-gfiles']            ,
          \ 'b' : ['Buffers'    , 'fzf-buffers']           ,
          \ 'Co': ['Color'      , 'fzf-color']             ,
          \ 'r' : ['Rg'         , 'fzf-ripgrep']           ,
          \ 'L' : ['Lines'      , 'fzf-lines']             ,
          \ 'l' : ['BLines'     , 'fzf-buffer-lines']      ,
          \ 'T' : ['Tags'       , 'fzf-tags']              ,
          \ 't' : ['BTags'      , 'fzf-buffer-tags']       ,
          \ 'm' : ['Marks'      , 'fzf-marks']             ,
          \ 'w' : ['Windows'    , 'fzf-windows']           ,
          \ 'HH': ['History'    , 'fzf-history']           ,
          \ 'H' : ['History:'   , 'fzf-commands-history']  ,
          \ 'h' : ['History/'   , 'fzf-search-history']    ,
          \ 's' : ['Snippets'   , 'fzf-snippets']          ,
          \ 'C' : ['Commits'    , 'fzf-buffer-commits']    ,
          \ 'c' : ['BCommits'   , 'fzf-buffer-commits']    ,
          \ 'CC': ['Commands'   , 'fzf-commands']          ,
          \ 'M' : ['Maps'       , 'fzf-maps']              ,
          \ 'Ht': ['Helptags'   , 'fzf-help-tags']         ,
          \ 'F' : ['Filetypes'  , 'fzf-filetypes']         ,
          \ }

        autocmd! FileType which_key
        autocmd  FileType which_key set laststatus=0 noshowmode noruler
          \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler


        "" TODO: implement the following leader key mapping
        "" https://github.com/kshenoy/vim-signature#installation

      '';
    }

    # LANGUAGE SUPPORT (HIGHLIGHTING)
    { plugins = with vimPlugins; [
        # A collection of language packs for Vim.
        # https://github.com/sheerun/vim-polyglot
        vim-polyglot
      ];
      config = ''
        " need to disable its default elm plugin so that vim-elm-syntax is being used
        let g:polyglot_disabled = ['elm']
      '';
    }


    # VERSION CONTROL
    { plugins = with vimPlugins; [
        # A Git wrapper
        # https://github.com/tpope/vim-fugitive
        vim-fugitive
        # Plugin which manipulate gists in Vim.
        # https://github.com/lambdalisue/vim-gista
        vim-gista
        # Show a diff using Vim its sign column.
        # https://github.com/mhinz/vim-signify
        vim-signify
      ];
      config = ''
        let g:which_key_map.g = {
                \'name' : 'Git Menu',
                \'s' : ['Gstatus', 'Git Status'],
                \'p' : ['Gpull',   'Git Pull'],
                \'u' : ['Gpush',   'Git Push'],
                \'c' : ['Gcommit', 'Git Commit'],
                \'w' : ['Gwrite',  'Git Write'],
                \'i' : ['Gista post --public',  'Public Gist'],
                \'I' : ['Gista post --private',  'Private Gist'],
                \}
      '';
    }

    # NAVIGATION
    { plugins = with vimPlugins; [
        # Plugin to toggle, display and navigate marks
        # https://github.com/kshenoy/vim-signature
        vim-signature
        # TODO:
        fzfWrapper
        fzf-vim
        vim-rooter
        coc-fzf
      ];
      config = ''
        "nnoremap <silent> <space>a  :<C-u>CocFzfList diagnostics<CR>
        "nnoremap <silent> <space>b  :<C-u>CocFzfList diagnostics --current-buf<CR>
        "nnoremap <silent> <space>c  :<C-u>CocFzfList commands<CR>
        "nnoremap <silent> <space>e  :<C-u>CocFzfList extensions<CR>
        "nnoremap <silent> <space>l  :<C-u>CocFzfList location<CR>
        "nnoremap <silent> <space>o  :<C-u>CocFzfList outline<CR>
        "nnoremap <silent> <space>s  :<C-u>CocFzfList symbols<CR>
        "nnoremap <silent> <space>S  :<C-u>CocFzfList services<CR>
        "nnoremap <silent> <space>p  :<C-u>CocFzfListResume<CR>

        " FZF floating window
        let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }
      '';
    }

    # EDITING
    { plugins = with vimPlugins; [
        # AutoSave - automatically save changes to disk without having to
        # use :w (or any binding to it) every time a buffer has been modified.
        # https://github.com/vim-scripts/vim-auto-save
        vim-auto-save
        # TODO:
        vim-expand-region
        # Focused mode
        goyo-vim
      ];
      config = ''
        " Use region expanding
        vmap v <Plug>(expand_region_expand)
        vmap <C-v> <Plug>(expand_region_shrink)

        " toggle spelling
        set invspell
        nnoremap <leader>s :set invspell<CR>
      '';
    }

    # PROGRAMMING (GENERAL)
    { plugins = with vimPlugins; [
        # TODO: https://github.com/neoclide/coc.nvim/wiki/Using-coc-extensions#use-vims-plugin-manager-for-coc-extension
        coc-nvim
        coc-json
        coc-snippets
        # TODO: coc-diagnostic
        # TODO: coc-dictionary
        # TODO: coc-github
        coc-highlight
        # TODO: coc-project
        coc-lists
        # TODO: coc-emoji
        coc-pairs
        # TODO: coc-sh
        coc-spell-checker
        coc-lua
        # TODO: coc-syntax
        # TODO: coc-xml # needs java
        # TODO: coc-tabnine
        # TODO: coc-tag
        # TODO: coc-translator
        # TODO: coc-vimlsp
        coc-yaml
        coc-yank
        # TODO: coc-word
        vim-snippets
        vim-commentary
      ];
      config = ''
        let g:coc_node_path = '${nodejs}/bin/node'

        " Use <Tab> and <S-Tab> for navigate completion list:
        inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
        inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

        " Use <cr> to confirm complete
        inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

        " Close preview window when completion is done.
        autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

        " show signature help of current function
        autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
        " Use K for show documentation in preview window
        "nnoremap <silent> K :call <SID>show_documentation()<CR>

        " You must set foldmethod=manual in your vimrc, one set Coc will handle
        " folding with the usual commands, zc, zo, etc
        set foldmethod=manual

        nmap <silent> gr <Plug>(coc-references)
        nmap <leader>rn <Plug>(coc-rename)
        nmap <silent> gd <Plug>(coc-definition)
        nmap <silent> gy <Plug>(coc-type-definition)

        nmap <leader>r <Plug>(coc-rename)
        nmap <silent> <leader>s <Plug>(coc-fix-current)
        nmap <silent> <leader>S <Plug>(coc-codeaction)
        nmap <silent> <leader>a <Plug>(coc-diagnostic-next)
        nmap <silent> <leader>A <Plug>(coc-diagnostic-next-error)
        nmap <silent> <leader>d <Plug>(coc-definition)
        nmap <silent> <leader>g :call CocAction('doHover')<CR>
        nmap <silent> <leader>u <Plug>(coc-references)
        nmap <silent> <leader>p :call CocActionAsync('format')<CR>
      '';
    }

    # PROGRAMMING (RUST)
    { plugins = with vimPlugins; [
        #rust-vim
        # https://github.com/neoclide/coc-rls
        coc-rls
      ];
      config = ''
      '';
    }

    # PROGRAMMING (PYTHON)
    { plugins = with vimPlugins; [
        coc-python
      ];
      config = ''
      '';
    }

    # PROGRAMMING (HTML/CSS/JS/SVG)
    { plugins = with vimPlugins; [
        coc-css
        coc-html
        #coc-jest
        #coc-eslint
        coc-tsserver
        coc-tslint-plugin
        #coc-prettier
      ];
      config = ''
      '';
    }

    # PROGRAMMING (ELM)
    { plugins = with vimPlugins; [
        vim-elm-syntax
      ];
      config = ''
      '';
    }

    # PROGRAMMING (NIX)
    { plugins = with vimPlugins; [
        # Support for writing Nix expressions in vim.
        # https://github.com/LnL7/vim-nix
        vim-nix
      ];
      config = ''
      '';
    }

    # PROGRAMMING (DHALL)
    { plugins = with vimPlugins; [
        dhall-vim
      ];
      config = ''
      '';
    }

    # TODO: PROGRAMMING (C++)
    { plugins = with vimPlugins; [
      ];
      config = ''
      '';
    }
  ];

in neovim.override {
  vimAlias = true;
  configure = {
    customRC = preConfig + (builtins.concatStringsSep "\n\n" (builtins.map (x: x.config) pluginsWithConfig)) + postConfig;
    packages.myVimPackages = {
      start = lib.flatten (builtins.map (x: x.plugins) pluginsWithConfig);
    };
  };
}
