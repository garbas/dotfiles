{ pkgs ? import <nixpkgs> {}
}:

let
  preConfig = ''
    let mapleader = "\<Space>"
    let maplocalleader = ","
  '';
  postConfig = ''
  '';
  pluginsWithConfig = [

    # SENSIBLE DEFAULTS
    { plugins = [
        # One step above 'nocompatible' mode
        # https://github.com/tpope/vim-sensible
        "sensible"
        # One step above sensible.vim more defaults to agree on
        # https://github.com/jeffkreeftmeijer/neovim-sensible
        "neovim-sensible"
      ];
      config = "";
    }

    # LANGUAGE SUPPORT (HIGHLIGHTING)
    { plugins = [
        # A collection of language packs for Vim.
        # https://github.com/sheerun/vim-polyglot
        "vim-polyglot"
        # Support for writing Nix expressions in vim.
        # https://github.com/LnL7/vim-nix
        "vim-nix"
      ];
      config = "";
    }

    # THEME
    { plugins = [
        "vim-one"
        "vim-airline"
        "vim-airline-themes"
        "vim-devicons"
      ];
      config = ''
        set termguicolors
        colorscheme one
        set background=light
        let g:one_allow_italics = 1
        let g:airline_theme='one'
      '';
    }

    # VERSION CONTROLS
    { plugins = [
        # A Git wrapper
        # https://github.com/tpope/vim-fugitive
        "fugitive"
        # Plugin which manipulate gists in Vim. 
        # https://github.com/lambdalisue/vim-gista
        "vim-gista"
      ];
      config = ''
      '';
    }

    # NAVIGATION
    { plugins = [
        # Plugin to toggle, display and navigate marks
        # https://github.com/kshenoy/vim-signature
        "vim-signature"
        # The fancy start screen for Vim.
        # https://github.com/mhinz/vim-startify
        "vim-startify"
        # Keymap-display loosely inspired by emacs's guide-key.
        # https://github.com/hecal3/vim-leader-guide
        "vim-leader-guide"
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

        " TODO: implement the following leader key mapping
        " https://github.com/kshenoy/vim-signature#installation
        let g:lmap =  {}

        " Git
        let g:lmap.g = {
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

    # EDITING
    { plugins = [
        # AutoSave - automatically save changes to disk without having to
        # use :w (or any binding to it) every time a buffer has been modified.
        # https://github.com/vim-scripts/vim-auto-save
        "vim-auto-save"
        # 
        "vim-expand-region"
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

    # "neoformat"
    # "commentary"
    # "ale"
    # "UltiSnips"
    # "vim-snippets"
    # "deoplete-nvim"
    # "fzf-vim"
    # "fzfWrapper"
    # "goyo"
    # "neoformat"
    # "neomake"
    # "vim-css-color"
  ];
in {
  customRC = preConfig +
             (builtins.concatStringsSep "\n\n" (builtins.map (x: x.config) pluginsWithConfig)) +
             postConfig;
  packages.myVimPackages = {
    start = map (name: pkgs.vimPlugins."${name}") (pkgs.lib.flatten (builtins.map (x: x.plugins) pluginsWithConfig));
  };
}
