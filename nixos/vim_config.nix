{ pkgs ? import <nixpkgs> {}
}:

let
  inherit (pkgs) fetchFromGitHub;

  yarn2nix-src = fetchFromGitHub {
    owner = "moretea";
    repo = "yarn2nix";
    rev = "780e33a07fd821e09ab5b05223ddb4ca15ac663f";
    sha256 = "1f83cr9qgk95g3571ps644rvgfzv2i4i7532q8pg405s4q5ada3h";
  };

  yarn2nix = import yarn2nix-src { inherit pkgs; };

  coc = yarn2nix.mkYarnPackage {
    name = "coc.nvim";
    src = ./coc.nvim;
    patchPhase = ''
      sed -i -e "s|if executable('yarn')|if executable('${pkgs.yarn}/bin/yarn')|" autoload/coc/util.vim
    '';
    postInstall = ''
      export HOME=$TMPDIR/coc-$RANDOM
      OLD_NODE_MODULES=`realpath $out/libexec/coc.nvim/deps/coc.nvim/node_modules`
      rm -rf $out/libexec/coc.nvim/deps/coc.nvim/node_modules
      mkdir $out/libexec/coc.nvim/deps/coc.nvim/node_modules
      for item in $out/libexec/coc.nvim/node_modules/*; do
        name=`basename $item`
        if [ "$name" == "coc.nvim" ]; then
          continue
        fi
        ln -s "$out/libexec/coc.nvim/node_modules/$name" "$out/libexec/coc.nvim/deps/coc.nvim/node_modules/$name"
      done
      if [ -e "$out/libexec/coc.nvim/node_modules/.bin" ]; then
        ln -s "$out/libexec/coc.nvim/node_modules/.bin" "$out/libexec/coc.nvim/deps/coc.nvim/node_modules/.bin"
      fi
      pushd $out/libexec/coc.nvim/deps/coc.nvim
        yarn build
      popd
    '';

  };

  vimPlugins = pkgs.lib.fix' (pkgs.lib.extends
    (self: super: {

      coc = pkgs.vimUtils.buildVimPluginFrom2Nix {
        pname = "coc";
        version = "2019-04-04";
        src = "${coc}/libexec/coc.nvim/deps/coc.nvim";
      };

    })
    (self: pkgs.vimPlugins));

  preConfig = ''
    let mapleader="\<Space>"
    let maplocalleader = ","
  '';
  postConfig = ''
  '';
  pluginsWithConfig = with vimPlugins; [

    # SENSIBLE DEFAULTS
    { plugins = [
        # One step above 'nocompatible' mode
        # https://github.com/tpope/vim-sensible
        sensible

        # One step above sensible.vim more defaults to agree on
        # https://github.com/jeffkreeftmeijer/neovim-sensible
        neovim-sensible
      ];
      config = "";
    }

    # THEME
    { plugins = [
        vim-one
        vim-airline
        vim-airline-themes
        vim-devicons
      ];
      config = ''
        set termguicolors
        colorscheme one
        set background=light
        let g:one_allow_italics = 1
        let g:airline_theme='one'

        let g:airline_section_error = '%{airline#util#wrap(airline#extensions#coc#get_error(),0)}'
        let g:airline_section_warning = '%{airline#util#wrap(airline#extensions#coc#get_warning(),0)}'
      '';
    }

    # CORE
    { plugins = [
        # The fancy start screen for Vim.
        # https://github.com/mhinz/vim-startify
        vim-startify

        # Keymap-display loosely inspired by emacs's guide-key.
        # https://github.com/hecal3/vim-leader-guide
        vim-leader-guide
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

        let g:lmap =  {}

        "" Git
        "let g:lmap.g = {
        "        \'name' : 'Git Menu',
        "        \'s' : ['Gstatus', 'Git Status'],
        "        \'p' : ['Gpull',   'Git Pull'],
        "        \'u' : ['Gpush',   'Git Push'],
        "        \'c' : ['Gcommit', 'Git Commit'],
        "        \'w' : ['Gwrite',  'Git Write'],
        "        \'i' : ['Gista post --public',  'Public Gist'],
        "        \'I' : ['Gista post --private',  'Private Gist'],
        "        \}

        " TODO: implement the following leader key mapping
        " https://github.com/kshenoy/vim-signature#installation

        "call leaderGuide#register_prefix_descriptions("<Space>", "g:lmap")
        nnoremap <silent> <leader> :<c-u>LeaderGuide '<Space>'<CR>
        vnoremap <silent> <leader> :<c-u>LeaderGuideVisual '<Space>'<CR>

      '';
    }

    # LANGUAGE SUPPORT (HIGHLIGHTING)
    { plugins = [
        # A collection of language packs for Vim.
        # https://github.com/sheerun/vim-polyglot
        vim-polyglot
        # Support for writing Nix expressions in vim.
        # https://github.com/LnL7/vim-nix
        vim-nix
      ];
      config = "";
    }


    # VERSION CONTROLS
    { plugins = [
        # A Git wrapper
        # https://github.com/tpope/vim-fugitive
        fugitive
        # Plugin which manipulate gists in Vim. 
        # https://github.com/lambdalisue/vim-gista
        vim-gista
        # Show a diff using Vim its sign column.
        # https://github.com/mhinz/vim-signify
        vim-signify
      ];
      config = ''
      '';
    }

    # NAVIGATION
    { plugins = [
        # Plugin to toggle, display and navigate marks
        # https://github.com/kshenoy/vim-signature
        vim-signature
      ];
      config = ''
      '';
    }

    # EDITING
    { plugins = [
        # AutoSave - automatically save changes to disk without having to
        # use :w (or any binding to it) every time a buffer has been modified.
        # https://github.com/vim-scripts/vim-auto-save
        vim-auto-save
        # 
        vim-expand-region
        # Focused mode
        goyo
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
    { plugins = [
        # TODO: https://github.com/neoclide/coc.nvim/wiki/Using-coc-extensions#use-vims-plugin-manager-for-coc-extension
        coc
        vim-snippets
        vim-commentary
      ];
      config = ''
        let g:coc_node_path = '${pkgs.nodejs}/bin/node'

        " Use <Tab> and <S-Tab> for navigate completion list:
        inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
        inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

        " Use <cr> to confirm complete
        inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

        " Close preview window when completion is done.
        autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif


      '';
    }

    # # PROGRAMMING (RUST)
    # { plugins = [
    #   ];
    #   config = ''
    #   '';
    # }

  ];

in {
  customRC = preConfig +
             (builtins.concatStringsSep "\n\n" (builtins.map (x: x.config) pluginsWithConfig)) +
             postConfig;
  packages.myVimPackages = {
    start = pkgs.lib.flatten (builtins.map (x: x.plugins) pluginsWithConfig);
  };
}
