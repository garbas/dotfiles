{ pkgs ? import <nixpkgs> {} }:

{ 
  weechat = pkgs.weechat.override {
    extraBuildInputs = [ pkgs.pythonPackages.websocket_client ];
  };

  ttf_bitstream_vera = pkgs.callPackage ./ttf_bitstream_vera {
    inherit (pkgs) stdenv fetchgit;
  };

  st = pkgs.st.override {
    conf = import ./st_config.nix {
      theme = builtins.readFile "${pkgs.base16}/st/base16-default.light.c";
    };
  };

  zsh_prezto = pkgs.stdenv.mkDerivation rec {
    name = "zsh-prezto-2015";
    configFile = pkgs.writeText "zpreztorc" (import ./zsh_config.nix { inherit pkgs; });
    srcs = [
      (pkgs.fetchgit {
         rev = "f2a826e963f06a204dc0e09c05fc3e5419799f52";
         url = "https://github.com/sorin-ionescu/prezto";
         sha256 = "92eabf5247a878c57e045988a2475021f9a345de8c9a3bcc05f2b42dc4711c6d";
         })
      (pkgs.fetchgit {
         rev = "d05089b7fd211d201b9519ca5321b60544082c19";
         url = "https://github.com/garbas/nix-zsh-completions";
         sha256 = "0cb26f211f56bc27ac81f31b8f05616c21095238034b36db35dbc1cff986255a";
         })
    ];
    sourceRoot = "prezto-f2a826e";
    installPhase = ''
      mkdir -p $out/modules/nix

      sed -i -e "s|\''${ZDOTDIR:\-\$HOME}/.zpreztorc|${configFile}|g" init.zsh
      sed -i -e "s|\''${ZDOTDIR:\-\$HOME}/.zprezto/|$out/|g" init.zsh
      for i in runcoms/*; do
        sed -i -e "s|\''${ZDOTDIR:\-\$HOME}/.zprezto/|$out/|g" $i
      done
      sed -i -e "s|\''${0:h}/cache.zsh|\''${ZDOTDIR:\-\$HOME}/.zfasd_cache|g" modules/fasd/init.zsh

      cp ../nix-zsh-completions-d05089b/* $out/modules/nix -R
      cp ./* $out/ -R
    '';
  };

  neovim = pkgs.neovim.override {
    vimAlias = true;
    configure = {
      customRC = ''
        if has('nvim')
          tnoremap <Esc> <C-\><C-n>
          tnoremap <C-h> <C-\><C-n><C-w>h
          tnoremap <C-j> <C-\><C-n><C-w>j
          tnoremap <C-k> <C-\><C-n><C-w>k
          tnoremap <C-l> <C-\><C-n><C-w>l
          autocmd BufWinEnter,WinEnter term://* startinsert
          autocmd BufLeave term://* stopinsert
        endif

        let mapleader = "\<Space>"
        let maplocalleader = ","

        let g:ctrlp_dont_split = 'NERD_tree_2'
        let g:ctrlp_extensions = ['undo', 'bookmarkdir', 'funky']
        let g:ctrlp_jump_to_buffer = 0
        let g:ctrlp_map = '<leader>o'
        let g:ctrlp_match_window_reversed = 1
        let g:ctrlp_max_height = 20
        let g:ctrlp_open_new_file = 'v'
        let g:ctrlp_open_multiple_files = '2vjr'
        let g:ctrlp_split_window = 0
        let g:ctrlp_working_path_mode = 'ra'
        let g:ctrlp_follow_symlinks = 1

        nnoremap <leader><leader> :CtrlPBuffer<cr>
        nnoremap <leader>b :CtrlPBookmarkDir<cr>
      '';
      vam.pluginDictionaries = [
        { names = [ "ctrlp" "youcompleteme" "vim-airline" ]; }
      ];
    };
  };
}
